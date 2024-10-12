defmodule Airlink.Companies.CompanyServer do
  use GenServer

  @table_name :companies_cache

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_company(uuid, company_info) do
    GenServer.call(__MODULE__, {:add_company, uuid, company_info})
  end

  def delete_company(uuid) do
    GenServer.call(__MODULE__, {:delete_company, uuid})
  end

  def update_company(uuid, company_info) do
    GenServer.call(__MODULE__, {:update_company, uuid, company_info})
  end

  def get_company(uuid) do
    GenServer.call(__MODULE__, {:get_company, uuid})
  end

  # Server Callbacks

  @impl true
  def init(_args) do
    table = :ets.new(@table_name, [:set, :protected, :named_table])
    {:ok, table}
  end

  @impl true
  def handle_call({:add_company, uuid, company_info}, _from, table) do
    result = :ets.insert(table, {uuid, company_info})
    {:reply, result, table}
  end

  @impl true
  def handle_call({:delete_company, uuid}, _from, table) do
    result = :ets.delete(table, uuid)
    {:reply, result, table}
  end

  @impl true
  def handle_call({:update_company, uuid, company_info}, _from, table) do
    result = :ets.insert(table, {uuid, company_info})
    {:reply, result, table}
  end

  @impl true
  def handle_call({:get_company, uuid}, _from, table) do
    result = case :ets.lookup(table, uuid) do
      [{^uuid, company_info}] -> {:ok, company_info}
      [] -> {:error, :not_found}
    end
    {:reply, result, table}
  end
end
