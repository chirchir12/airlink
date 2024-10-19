defmodule Airlink.Captive.CookierServer do
  use GenServer

  @table_name :captive_cookies

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_cookie(cookie, customer_id) do
    GenServer.call(__MODULE__, {:add_cookie, cookie, customer_id})
  end

  def delete_cookie(cookie) do
    GenServer.call(__MODULE__, {:delete_cookie, cookie})
  end

  def get_customer_id(cookie) do
    GenServer.call(__MODULE__, {:get_customer_id, cookie})
  end

  # Server Callbacks

  @impl true
  def init(_args) do
    table = :ets.new(@table_name, [:set, :protected, :named_table])
    {:ok, table}
  end

  @impl true
  def handle_call({:add_cookie, cookie, customer_id}, _from, table) do
    result = :ets.insert(table, {cookie, customer_id})

    {:reply, result, table}
  end

  @impl true
  def handle_call({:delete_cookie, cookie}, _from, table) do
    result = :ets.delete(table, cookie)
    {:reply, result, table}
  end

  @impl true
  def handle_call({:get_customer_id, cookie}, _from, table) do
    result =
      case :ets.lookup(table, cookie) do
        [{^cookie, customer_id}] -> {:ok, customer_id}
        [] -> {:error, :customer_not_found}
      end

    {:reply, result, table}
  end
end
