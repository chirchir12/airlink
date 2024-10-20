defmodule Airlink.Companies.CompanyHydration do
  use GenServer,  restart: :transient
  alias Airlink.HttpClient
  require Logger
  import Airlink.Helpers
  alias Airlink.Companies.CompanyServer
  alias Airlink.Companies.Company


   # Client
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Server (callbacks)

  @impl true
  def init(_args) do
    Logger.info("[#{inspect(__MODULE__)}]: Company Hydration initialized")
    {:ok, nil, {:continue, :hydrate_cache}}
  end

  @impl true
  def handle_continue(:hydrate_cache, state) do
    _ = get_companies()
    {:stop, :normal, state}
  end

  @impl true
  def terminate(:normal, _state) do
    Logger.info("[#{inspect(__MODULE__)}]: Done hydrating company cache: Terminating")
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.error("[#{inspect(__MODULE__)}]: Failed to hydrate company cache: Terminating")
  end

  # private
  defp get_companies() do
    with {:ok, :ok} <- handle_request() do
      :ok
    else
      _ ->
        :error
    end
  end

  defp handle_request() do
    config = get_config(:diralink)
    url = "#{config.base_url}/v1/api/system/companies"
    headers = basic_auth(config)

    case HttpClient.get(url, headers) do
      {:ok, response} -> handle_response(response)
      {:error, error} -> handle_error(error)
    end
  end

  defp handle_response(%HTTPoison.Response{status_code: 200, body: body}) do
    Logger.info("[#{inspect(__MODULE__)}]: Got companies from diralink")
    body
    |> atomize_map_keys()
    |> hydrate_cache()
  end


  defp handle_error(%HTTPoison.Error{id: nil, reason: reason}) do
    raise "HTTP request failed: #{inspect(reason)}"
  end

  defp hydrate_cache(%{data: companies}) when is_list(companies) and length(companies) > 0 do
    companies
    |> Enum.map(&atomize_map_keys/1)
    |> Enum.each(&save_company/1)

    {:ok, :ok}
  end

  defp hydrate_cache(companies) do
    Logger.warning("[#{inspect(__MODULE__)}]: Got zero companies: #{inspect(companies)}")
    {:ok, :ok}
  end

  defp save_company(%{company_id: company_id} = company) do
    CompanyServer.add_company(company_id, Company.new(company))
  end
end
