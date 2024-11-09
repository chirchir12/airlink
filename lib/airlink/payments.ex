defmodule Airlink.Payments do
  alias __MODULE__.Payment
  alias Airlink.Plans.Plan
  alias Airlink.Subscriptions
  alias Airlink.Subscriptions.Subscription
  alias Airlink.HttpClient
  import Airlink.Helpers
  alias Airlink.Customers
  require Logger

  def create(%Plan{} = plan, params) do
    with subs_params <- subscription_params(plan, params),
         {:ok, subscription} <- Subscriptions.create_subscription(subs_params),
         {:ok, response} <- create_payment(params, plan, subscription) do
      :ok = Logger.debug("Created Transaction - #{inspect(response)}")
      {:ok, subscription}
    end
  end

  def check_status(subscription_uuid) do
    Subscriptions.get_subscription_by_uuid(subscription_uuid)
  end

  def validate(params) do
    %Payment{}
    |> Payment.changeset(params)
    |> case do
      %{valid?: true, changes: changes} -> {:ok, changes}
      changeset -> {:error, changeset}
    end
  end

  def update_payments(txn_params) do
    with {:ok, sub} <- update_subscription_status(txn_params),
         {:ok, _customer} <- update_customer_status(txn_params) do
      maybe_publish_to_radius(sub)
    end
  end

  defp maybe_publish_to_radius(%Subscription{status: "completed"} = sub) do
    Airlink.publish(sub)
  end

  defp maybe_publish_to_radius(_sub) do
    :ok
  end

  defp update_customer_status(%{status: "completed"} = txn_params) do
    with {:ok, customer} <- Customers.get_customer_by_uuid(txn_params.customer_id) do
      params = %{status: "active"}
      Customers.update_customer(customer, params)
    end
  end

  defp update_customer_status(%{status: status} = txn_params)
       when status in ["stale", "failed"] do
    with {:ok, customer} <- Customers.get_customer_by_uuid(txn_params.customer_id) do
      params = %{status: "inactive"}
      Customers.update_customer(customer, params)
    end
  end

  defp update_subscription_status(%{status: "completed"} = txn_params) do
    with {:ok, sub} <- Subscriptions.get_subscription_by_uuid(txn_params.request_id) do
      params = %{status: "completed"}
      Subscriptions.update_subscription(sub, params)
    end
  end

  defp update_subscription_status(%{status: status} = txn_params)
       when status in ["failed", "stale"] do
    with {:ok, sub} <- Subscriptions.get_subscription_by_uuid(txn_params.request_id) do
      params = %{status: "failed"}
      Subscriptions.update_subscription(sub, params)
    end
  end

  defp subscription_params(%Plan{id: id, price: price}, params) do
    %{
      status: "pending",
      company_id: params.company_id,
      plan_id: id,
      customer_id: params.customer_id,
      meta: %{
        amount: price,
        phone_number: params.phone_number
      }
    }
  end

  defp create_payment(params, %Plan{} = plan, %Subscription{} = subscription) do
    with request <- payment_request(params, plan, subscription),
         {:ok, response} <- handle_request(request, subscription) do
      {:ok, response}
    end
  end

  defp handle_request(request, subscription) do
    config = get_config(:diralink)
    url = "#{config.base_url}/v1/api/system/payments"
    headers = basic_auth(config)

    request = %{
      params: request
    }

    case HttpClient.post(url, request, headers) do
      {:ok, response} -> handle_response(response, subscription)
      {:error, error} -> handle_error(error, subscription)
    end
  end

  defp handle_response(%HTTPoison.Response{status_code: 202, body: body}, _sub) do
    {:ok, body}
  end

  defp handle_response(%HTTPoison.Response{} = resp, subscription) do
    params = %{status: "failed"}
    {:ok, _sub} = Subscriptions.update_subscription(subscription, params)
    :ok = Logger.error("Failed to create payment: #{inspect(resp)}")
    {:error, :unknown_transaction_error}
  end

  defp handle_error(%HTTPoison.Error{id: nil, reason: reason}, subscription) do
    params = %{status: "failed"}
    {:ok, _sub} = Subscriptions.update_subscription(subscription, params)
    {:error, reason}
  end

  defp payment_request(params, %Plan{price: price, uuid: uuid}, %Subscription{uuid: sub_uuid}) do
    %{
      phone_number: params.phone_number,
      amount: price,
      plan_id: uuid,
      company_id: params.company_id,
      customer_id: params.customer_uuid,
      transaction_type: "c2b",
      description: "Hotspot Payment",
      request_id: sub_uuid,
      service: "hotspot"
    }
  end
end
