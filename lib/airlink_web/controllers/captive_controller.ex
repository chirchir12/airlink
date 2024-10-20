defmodule AirlinkWeb.CaptiveController do
  use AirlinkWeb, :controller
  alias Airlink.Captive
  alias Airlink.Customers
  alias Airlink.Companies
  alias Airlink.Subscriptions
  alias Airlink.Routers
  alias Airlink.Customers.Customer
  alias Airlink.Hotspots
  alias Airlink.Helpers
  action_fallback AirlinkWeb.FallbackController

  def create(conn, params) do
    with {:ok, {params, _company, _router, _hotspot}} <- validate(conn, params),
         {:ok, %Customer{uuid: uuid} = customer} <-
           Customers.get_or_create_customer(params.mac, params.company_id),
         {:ok, %{cookie: cookie}} <- Captive.create_entry(customer, params),
         {:ok, :resubscribe} <- handle_subscription_check(conn, customer, cookie) do
      config = get_config()
      url = "#{config.base_url}/#{config.login_uri}?customer_id=#{uuid}&isp=#{params.company_id}"

      conn
      |> put_resp_cookie("airlink_hotspot_cookie", cookie, max_age: 600)
      |> redirect(external: url)
    end
  end

  defp validate(conn, params) do
    with {:ok, params} <- handle_validation_check(conn, params),
         {:ok, company} <- handle_company_check(conn, params.company_id),
         {:ok, router} <- handle_router_check(conn, params.router_id),
         {:ok, hotspot} <- handle_hotspot_check(conn, params.hotspot_id) do
      {:ok, {params, company, router, hotspot}}
    end
  end

  defp handle_company_check(conn, company_id) do
    case Companies.get_company(company_id) do
      {:ok, company} -> handle_disabled_campanies(conn, company)
      {:error, error} -> handle_redirection(conn, error)
    end
  end

  defp handle_disabled_campanies(_conn, %{enabled: true} = company) do
    {:ok, company}
  end

  defp handle_disabled_campanies(conn, %{enabled: false}) do
    handle_redirection(conn, :suspended_isp)
  end

  defp handle_validation_check(conn, params) do
    case Captive.validate(params) do
      {:ok, params} -> {:ok, params}
      {:error, _changeset} -> handle_redirection(conn, :validation_error)
    end
  end

  defp handle_router_check(conn, router_id) do
    case Routers.get_router(router_id) do
      {:ok, router} -> {:ok, router}
      {:error, error} -> handle_redirection(conn, error)
    end
  end

  defp handle_hotspot_check(conn, hotspot_uuid) do
    case Hotspots.get_hotspot_by_uuid(hotspot_uuid) do
      {:ok, hotspot} -> {:ok, hotspot}
      {:error, error} -> handle_redirection(conn, error)
    end
  end

  defp handle_subscription_check(
         conn,
         %Customer{id: customer_id, company_id: company_id},
         cookie
       ) do
    case Subscriptions.get_subscription(company_id, customer_id) do
      {:error, _error} -> {:ok, :resubscribe}
      {:ok, subs} -> handle_subs_status(conn, subs, cookie)
    end
  end

  defp handle_subs_status(conn, sub, cookie) do
    case Subscriptions.check_status(sub) do
      {:expired, _sub} -> {:ok, :resubscribe}
      {:not_expired, _sub} -> login(conn, sub, cookie)
    end
  end

  defp handle_redirection(conn, error_name) do
    config = get_config()
    url = "#{config.base_url}/#{config[error_name]}"
    redirect(conn, external: url)
  end

  defp login(conn, ref_id, cookie) do
    # User is still active
    config = get_config()
    url = "#{config.base_url}/#{config.login_uri}/#{ref_id}"

    conn
    |> put_resp_cookie("airlink_hotspot_cookie", cookie, max_age: 600)
    |> redirect(external: url)
  end

  defp get_config() do
    :airlink
    |> Application.get_env(:captive)
    |> Helpers.kw_to_map()
  end
end
