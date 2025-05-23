defmodule Airlink.Subscriptions do
  @moduledoc """
  The Subscriptions context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias Airlink.Repo
  alias Airlink.Subscriptions.Subscription
  alias Airlink.Plans
  alias Airlink.Plans.Plan
  alias Airlink.Customers
  alias Airlink.Customers.Customer
  alias Airlink.Subscriptions.Reactivate

  @doc """
  Returns the list of subscriptions.

  ## Examples

      iex> list_subscriptions()
      [%Subscription{}, ...]

  """
  def list_subscriptions do
    Repo.all(Subscription)
  end

  @doc """
  Gets a single subscription.

  Raises `Ecto.NoResultsError` if the Subscription does not exist.

  ## Examples

      iex> get_subscription!(123)
      %Subscription{}

      iex> get_subscription!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription_by_id(id) do
    case Repo.get(Subscription, id) do
      nil -> {:error, :subscription_not_found}
      subscription -> {:ok, subscription}
    end
  end

  def get_subscription_by_uuid(uuid) do
    case Repo.get_by(Subscription, uuid: uuid) do
      nil -> {:error, :subscription_not_found}
      subscription -> {:ok, subscription}
    end
  end

  def get_subscription(company_id, customer_id) do
    query =
      from s in Subscription,
        where: s.company_id == ^company_id and s.customer_id == ^customer_id,
        order_by: [desc: s.id],
        limit: 1

    case Repo.one(query) do
      nil -> {:error, :subscription_not_found}
      subscription -> {:ok, subscription}
    end
  end

  def get_subscription(company_id, customer_id, plan_id) do
    query =
      from s in Subscription,
        where:
          s.company_id == ^company_id and s.customer_id == ^customer_id and s.plan_id == ^plan_id,
        order_by: [desc: s.id],
        limit: 1

    case Repo.one(query) do
      nil -> {:error, :subscription_not_found}
      subscription -> {:ok, subscription}
    end
  end

  def check_status(%Subscription{expires_at: expire_at} = sub) do
    case is_expired(expire_at) do
      false -> {:not_expired, sub}
      true -> {:expired, sub}
    end
  end

  def validate_reactivation(params) do
    reactivation = %Reactivate{}
    changeset = Reactivate.changeset(reactivation, params)

    case changeset.valid? do
      false -> {:error, changeset}
      true -> {:ok, changeset.changes}
    end
  end

  @doc """
  Creates a subscription.

  ## Examples

      iex> create_subscription(%{field: value})
      {:ok, %Subscription{}}

      iex> create_subscription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription(attrs \\ %{}) do
    %Subscription{}
    |> Subscription.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subscription.

  ## Examples

      iex> update_subscription(subscription, %{field: new_value})
      {:ok, %Subscription{}}

      iex> update_subscription(subscription, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription(%Subscription{} = subscription, attrs) do
    subscription
    |> Subscription.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscription.

  ## Examples

      iex> delete_subscription(subscription)
      {:ok, %Subscription{}}

      iex> delete_subscription(subscription)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription(%Subscription{} = subscription) do
    Repo.delete(subscription)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription changes.

  ## Examples

      iex> change_subscription(subscription)
      %Ecto.Changeset{data: %Subscription{}}

  """
  def change_subscription(%Subscription{} = subscription, attrs \\ %{}) do
    Subscription.changeset(subscription, attrs)
  end

  def handle_radius_response(params) do
    handle_message(params)
  end

  # private
  defp is_expired(expire_time) when not is_nil(expire_time) do
    current_time = DateTime.utc_now()
    DateTime.compare(expire_time, current_time) == :lt
  end

  defp is_expired(_expire_time) do
    true
  end

  defp handle_message(params) when is_list(params) do
    params
    |> Enum.each(&handle_message/1)

    :ok
  end

  defp handle_message(%{action: "hotspot_session_expired", customer_id: uuid}) do
    with {:ok, customer} <- Customers.get_customer_by_uuid(uuid) do
      data = %{status: "inactive"}

      {:ok, _cus} =
        customer
        |> Customer.update_status_changeset(data)
        |> Repo.update()

      :ok
    else
      {:error, :customer_not_found} ->
        :ok = Logger.warning("Customer is deleted: reason: :customer_not_found")
        :ok

      error ->
        Logger.error("Could not handle message: reason: #{inspect(error)}")
        error
    end
  end

  defp handle_message(%{action: "hotspot_session_activated"} = params) do
    with {:ok, %Plan{id: plan_id}} <- Plans.get_plan_uuid(params.plan_id),
         {:ok, %Customer{company_id: company_id, id: customer_id} = cust} <-
           Customers.get_customer_by_uuid(params.customer_id),
         {:ok, subscription} <- get_subscription(company_id, customer_id, plan_id) do
      data = %{expires_at: params.expires_at}

      # update subscription
      {:ok, _sub} =
        subscription
        |> Subscription.update_expiry_changeset(data)
        |> Repo.update()

      data = %{status: "active"}

      {:ok, _cus} =
        cust
        |> Customer.update_status_changeset(data)
        |> Repo.update()

      :ok
    else
      {:error, :customer_not_found} ->
        :ok = Logger.warning("Customer is deleted: reason: :customer_not_found")
        :ok

      {:error, :plan_not_found} ->
        :ok = Logger.warning("Plan is deleted: reason: :plan_not_found")
        :ok

      {:error, :subscription_not_found} ->
        :ok = Logger.warning("Plan is deleted: reason: :plan_not_found")
        :ok

      error ->
        Logger.error("Could not handle message: reason: #{inspect(error)}")
        error
    end
  end

  defp handle_message(%{sender: "airlink"}) do
    :ok
  end

  defp handle_message(params) do
    Logger.warning("Message was not handled: #{inspect(params)}")
    :ok
  end
end
