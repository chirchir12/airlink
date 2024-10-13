defmodule Airlink.Captive.CaptiveServer do
  use GenServer

  @table_name :captive_cache

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_captive_entry(key, value) do
    GenServer.call(__MODULE__, {:add_captive_entry, key, value})
  end

  def delete_captive_entry(key) do
    GenServer.call(__MODULE__, {:delete_captive_entry, key})
  end

  def get_captive_entry(key) do
    GenServer.call(__MODULE__, {:get_captive_entry, key})
  end

  # Server Callbacks

  @impl true
  def init(_args) do
    table = :ets.new(@table_name, [:set, :protected, :named_table])
    {:ok, table}
  end

  @impl true
  def handle_call({:add_captive, key, entry}, _from, table) do
    result = :ets.insert(table, {key, entry})
    {:reply, result, table}
  end

  @impl true
  def handle_call({:delete_captive_entry, key}, _from, table) do
    result = :ets.delete(table, key)
    {:reply, result, table}
  end

  @impl true
  def handle_call({:get_captive_entry, key}, _from, table) do
    result =
      case :ets.lookup(table, key) do
        [{^key, entry}] -> {:ok, entry}
        [] -> {:error, :not_found}
      end

    {:reply, result, table}
  end
end
