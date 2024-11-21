defmodule Airlink.AccountingHandler do
  use Broadway
  alias Broadway.Message
  require Logger
  import Airlink.Helpers
  alias Airlink.Subscriptions
  alias Airlink.Repo

  def start_link(option) do
    Broadway.start_link(__MODULE__, [name: __MODULE__] ++ option)
  end

  def handle_message(_, %Message{data: params} = message, _ctx) do
    params = Jason.decode!(params) |> atomize_map_keys()

    with :ok <- process_message(params) do
      message
    else
      error ->
        Logger.error("Got error: #{inspect(error)}: Params: #{inspect(params)}")
        message
    end
  end

  def process_message(%{subscription_id: sub_id} = params) when is_nil(sub_id) or sub_id == "" do
    Logger.warning("Invalid accounting data: #{inspect(params)}")
    :ok
  end

  def process_message(%{subscription_id: sub_id} = params) do
    with {:ok, sub} <- Subscriptions.get_subscription_by_uuid(sub_id) do
      sub = Repo.preload(sub, :customer)
      params = Map.put(params, :user_name, sub.customer.username)
      params = Map.put(params, :company_id, sub.customer.company_id)
      params = Map.put(params, :updated_at, DateTime.utc_now())

      case Airlink.Accounting.handle_accounting_data(params) do
        {:ok, _} ->
          :ok

        {:error, reason} ->
          Logger.debug("Encountered error processing accounting data: #{inspect(params)}")
          Logger.error("Error processing accounting data: #{inspect(reason)}")
          :ok
      end
    end

    Logger.info("Processing message: #{inspect(params)}")
    :ok
  end
end
