defmodule Airlink.Routers.RouterServer do
  use GenServer
  import Airlink.Helpers
  alias Airlink.HttpClient

  require Logger

  @table_name :routers_cache

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_router(uuid, router_info) do
    GenServer.call(__MODULE__, {:add_router, uuid, router_info})
  end

  def delete_router(uuid) do
    GenServer.call(__MODULE__, {:delete_router, uuid})
  end

  def update_router(uuid, router_info) do
    GenServer.call(__MODULE__, {:update_router, uuid, router_info})
  end

  def get_router(uuid) do
    GenServer.call(__MODULE__, {:get_router, uuid})
  end

  # Server Callbacks

  @impl true
  def init(_args) do
    table = :ets.new(@table_name, [:set, :protected, :named_table])
    {:ok, table, {:continue, :hydrate_cache}}
  end

  @impl true
  def handle_call({:add_router, uuid, router_info}, _from, table) do
    result = :ets.insert(table, {uuid, router_info})
    {:reply, result, table}
  end

  @impl true
  def handle_call({:delete_router, uuid}, _from, table) do
    result = :ets.delete(table, uuid)
    {:reply, result, table}
  end

  @impl true
  def handle_call({:update_router, uuid, router_info}, _from, table) do
    result = :ets.insert(table, {uuid, router_info})
    {:reply, result, table}
  end

  @impl true
  def handle_call({:get_router, uuid}, _from, table) do
    result =
      case :ets.lookup(table, uuid) do
        [{^uuid, router_info}] -> {:ok, router_info}
        [] -> {:error, :router_not_found}
      end

    {:reply, result, table}
  end

  @impl true
  def handle_continue(:hydrate_cache, state) do
    _ = get_routers()
    {:noreply, state}
  end


  # private
  defp get_routers() do
    with {:ok, token} <- handle_auth_request(),
    {:ok, :ok} <- handle_request(token) do
      Logger.info("Routers Hydration Completed")
    else
      _ ->
        Logger.error("Routers Hydration Failed")
    end
  end

  defp handle_request(token) do
    config = get_config(:radius)
    url = "#{config.base_url}/v1/api/system/nas"
    headers = bearer_auth(token)

    case HttpClient.get(url, headers) do
      {:ok, response} -> handle_response(response)
      {:error, error} -> handle_error(error)
    end
  end

  defp handle_auth_request() do
    config = get_config(:diralink)
    url = "#{config.base_url}/v1/api/system/auth/login"
    headers = basic_auth(config)

    case HttpClient.get(url, headers) do
      {:ok, response} -> handle_auth_response(response)
      {:error, error} -> handle_error(error)
    end
  end

  defp handle_response(%HTTPoison.Response{status_code: 200, body: body}) do
    body.data
    |> atomize_map_keys()
    |> hydrate_cache()
  end

  defp handle_auth_response(%HTTPoison.Response{status_code: 200, body: body}) do
    %{data: %{access_token: token}} = body |> atomize_map_keys()
    {:ok, token}
  end

  defp handle_error(%HTTPoison.Error{id: nil, reason: reason}) do
    {:error, reason}
  end

  defp hydrate_cache(routers) when is_list(routers) and length(routers) > 0 do
    routers
    |> Enum.each(&save_router/1)

    {:ok, :ok}
  end

  defp hydrate_cache(routers) do
    Logger.warning("Got zero routers: #{inspect(routers)}")
    {:ok, :ok}
  end

  defp save_router(%{uuid: router_id} = router) do
    add_router(router_id, router)
  end

end
