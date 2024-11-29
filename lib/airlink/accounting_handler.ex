defmodule Airlink.AccountingHandler do
  use Broadway
  alias Broadway.Message
  require Logger
  import Airlink.Helpers
  alias Airlink.Subscriptions
  alias Airlink.Repo
  alias Airlink.AccessPoints
  alias Airlink.Hotspots

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
          :ok = update_acess_point(params)
          # :ok = update_hotspot(params)
          :ok

        {:error, reason} ->
          Logger.debug("Encountered error processing accounting data: #{inspect(params)}")
          Logger.error("Error processing accounting data: #{inspect(reason)}")
          :ok
      end
    end

    :ok
  end

  defp update_acess_point(%{calling_station_id: client_id} = params) do
    mac_address = client_id |> String.downcase()

    case AccessPoints.get_by_mac_address(mac_address, params.company_id) do
      {:error, :access_point_not_found} ->
        :ok

      {:ok, access_point} ->
        data = %{
          last_seen: params.updated_at,
          status: "online"
        }

        {:ok, _access_point} = AccessPoints.update_access_point(access_point, data)
        :ok
    end
  end

  # defp update_hotspot(%{called_station_id: hotspot_uuid} = params) do
  #   case Hotspots.get_hotspot_by_uuid(hotspot_uuid) do
  #     {:error, :hotspot_not_found} ->
  #       :ok

  #     {:ok, hotspot} ->
  #       data = %{status: "active", updated_at: params.updated_at}
  #       {:ok, _hotspot} = Hotspots.update_hotspot(hotspot, data)
  #       :ok
  #   end
  # end
end
