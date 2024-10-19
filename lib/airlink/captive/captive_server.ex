defmodule Airlink.Captive.CaptiveServer do
  use GenServer
  alias Airlink.Captive.CookierServer

  @table_name :captive_cache

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_captive_entry(customer_uuid, data) do
    GenServer.call(__MODULE__, {:add_captive_entry, customer_uuid, data})
  end

  def delete_captive_entry(customer_uuid) do
    GenServer.call(__MODULE__, {:delete_captive_entry, customer_uuid})
  end

  def get_captive_entry(customer_uuid) do
    GenServer.call(__MODULE__, {:get_captive_entry, customer_uuid})
  end

  def get_customer_id(cookie) do
    CookierServer.get_customer_id(cookie)
  end


  # Server Callbacks

  @impl true
  def init(_args) do
    table = :ets.new(@table_name, [:set, :protected, :named_table])
    {:ok, table}
  end

  @impl true
  def handle_call({:add_captive_entry, customer_uuid, {_customer, %{cookie: cookie}} =data}, _from, table) do
    result = :ets.insert(table, {customer_uuid, data})
    _= CookierServer.add_cookie(cookie, customer_uuid)

    {:reply, result, table}
  end

  @impl true
  def handle_call({:delete_captive_entry, customer_uuid}, _from, table) do
    result =
      case :ets.lookup(table, customer_uuid) do
        [{^customer_uuid, {_customer, %{cookie: cookie}}}] ->
          result = :ets.delete(table, customer_uuid)
          _= CookierServer.delete_cookie(cookie)
          {:ok, result}
        [] -> {:error, :customer_not_found}
      end
    {:reply, result, table}
  end

  @impl true
  def handle_call({:get_captive_entry, customer_uuid}, _from, table) do
    result =
      case :ets.lookup(table, customer_uuid) do
        [{^customer_uuid, data}] -> {:ok, data}
        [] -> {:error, :customer_not_found}
      end

    {:reply, result, table}
  end
end
