defmodule Airlink.Routers.RouterHydration do
  use GenServer, restart: :transient
  alias Airlink.HttpClient
  require Logger
  import Airlink.Helpers
  alias Airlink.Routers.RouterServer
  alias Airlink.Routers.Router

  # Client
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Server (callbacks)

  @impl true
  def init(_args) do
    Logger.info("[#{inspect(__MODULE__)}]: Router Hydration initialized")
    {:ok, nil, {:continue, :hydrate_cache}}
  end

  @impl true
  def handle_continue(:hydrate_cache, state) do
    _ = get_routers()
    {:stop, :normal, state}
  end

  @impl true
  def terminate(:normal, _state) do
    Logger.info("[#{inspect(__MODULE__)}]: Done hydrating router server: Terminating")
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.error("[#{inspect(__MODULE__)}]: Failed to hydrate router server: Terminating")
  end

  # private
  defp get_routers() do
    with {:ok, token} <- handle_auth_request(),
         {:ok, :ok} <- handle_request(token) do
      :ok
    else
      _ ->
        :error
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
    Logger.info("[#{inspect(__MODULE__)}]: Got routers from radius")

    body
    |> atomize_map_keys()
    |> hydrate_cache()
  end

  defp handle_auth_response(%HTTPoison.Response{status_code: 200, body: body}) do
    Logger.info("[#{inspect(__MODULE__)}]: Got Access token from diralink")
    %{data: %{access_token: token}} = body |> atomize_map_keys()
    {:ok, token}
  end

  defp handle_error(%HTTPoison.Error{id: nil, reason: reason}) do
    raise "HTTP request failed: #{inspect(reason)}"
  end

  defp hydrate_cache(%{data: routers}) when is_list(routers) and length(routers) > 0 do
    routers
    |> Enum.map(&atomize_map_keys/1)
    |> Enum.each(&save_router/1)

    {:ok, :ok}
  end

  defp hydrate_cache(routers) do
    Logger.warning("[#{inspect(__MODULE__)}]: Got zero routers: #{inspect(routers)}")
    {:ok, :ok}
  end

  defp save_router(%{uuid: router_id} = router) do
    RouterServer.add_router(router_id, Router.new(router))
  end
end
