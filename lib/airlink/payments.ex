defmodule Airlink.Payments do
  alias __MODULE__.Payment
  alias Airlink.Plans.Plan
  alias Airlink.Subscriptions
  alias Airlink.Subscriptions.Subscription
  alias Airlink.HttpClient
  import Airlink.Helpers
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
         {:ok, response} <- handle_request(request) do
      {:ok, response}
    end
  end

  defp handle_request(request) do
    config = get_config(:diralink)
    url = "#{config.base_url}/payments"
    headers = basic_auth(config)

    case HttpClient.post(url, request, headers) do
      {:ok, response} -> handle_response(response)
      {:error, error} -> handle_error(error)
    end
  end

  defp handle_response(%HTTPoison.Response{status_code: 202, body: body}) do
    {:ok, body}
  end

  defp handle_error(%HTTPoison.Error{id: nil, reason: reason}) do
    {:error, reason}
  end

  defp payment_request(params, %Plan{price: price, uuid: uuid}, %Subscription{uuid: sub_uuid}) do
    %{
      phone_number: params.phone_number,
      amount: price,
      package_id: uuid,
      company_id: params.company_id,
      customer_id: params.customer_id,
      transaction_type: "c2b",
      description: "Hotspot Payment",
      ref_id: sub_uuid
    }
  end

  defp basic_auth(config) do
    credentials = Base.encode64("#{config.username}:#{config.password}")
    [{"Authorization", "Basic #{credentials}"}]
  end
end
