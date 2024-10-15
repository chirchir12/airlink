defmodule Airlink.Routers.RouterServer do
  use GenServer

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
    {:ok, table, {:continiue, :hydrate_cache}}
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
end
