defmodule Airlink.Companies.CompanyServer do
  require Logger
  use GenServer
  import Airlink.Helpers
  alias Airlink.HttpClient

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
    {:ok, table, {:continue, :hydrate_cache}}
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
    result =
      case :ets.lookup(table, uuid) do
        [{^uuid, company_info}] -> {:ok, company_info}
        [] -> {:error, :company_not_found}
      end

    {:reply, result, table}
  end

  @impl true
  def handle_continue(:hydrate_cache, state) do
    _ = get_companies()
    {:noreply, state}

  end

  # private
  defp get_companies() do
    with {:ok, :ok} <- handle_request() do
      Logger.info("Company Hydration Completed")
    else
      _ ->
        Logger.info("Company Hydration Failed")

    end
  end

  defp handle_request() do
    config = get_config(:diralink)
    url = "#{config.base_url}/v1/system/companies"
    headers = basic_auth(config)

    case HttpClient.get(url, headers) do
      {:ok, response} -> handle_response(response)
      {:error, error} -> handle_error(error)
    end
  end

  defp handle_response(%HTTPoison.Response{status_code: 200, body: body}) do
    body.data
    |> atomize_map_keys()
    |> hydrate_cache()

  end

  defp handle_error(%HTTPoison.Error{id: nil, reason: reason}) do
    {:error, reason}
  end

  defp hydrate_cache(companies) when is_list(companies) and length(companies) > 0 do
    companies
    |> Enum.each(&save_company/1)

    { :ok, :ok}
  end

  defp hydrate_cache(companies) do
    Logger.warning("Got zero companies: #{inspect(companies)}")
   { :ok, :ok}
  end

  defp save_company(%{company_oid: company_id} = company) do
    add_company(company_id, company)
  end
end
