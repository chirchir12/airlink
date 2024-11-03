defmodule AirlinkWeb.RateLimitPlug do
  import Plug.Conn
  import Phoenix.Controller
  alias Airlink.Captive.CaptiveRateLimiter

  def init(default), do: default

  def call(%Plug.Conn{assigns: %{is_captive: true}} = conn, _) do
    captive_rate_limit(conn)
  end

  def call(conn, _) do
    conn
  end

  defp captive_rate_limit(%Plug.Conn{body_params: %{"mac" => mac_addr}} = conn) do
    rate_limit(conn, mac_addr)
  end

  defp rate_limit(conn, mac_addr) do
    now = System.monotonic_time(:second)

    case CaptiveRateLimiter.lookup(mac_addr) do
      {:error, _} ->
        CaptiveRateLimiter.increment_count(mac_addr, now, 1)
        conn

      {:ok, rate_limit_data} ->
        handle_rate_limit(conn, rate_limit_data)
    end
  end

  defp handle_rate_limit(conn, {mac_addr, last_timestamp, count}) do
    opts = captive_options()
    rate_limit_opt = opts[:rate_limit]
    max_requests = rate_limit_opt[:max_requests]
    allowed_time_window = rate_limit_opt[:allowed_window_in_sec]
    reset_after = rate_limit_opt[:reset_after_in_ms]
    url = opts[:base_url]
    uri = opts[:rate_limit_error_uri]
    url = "#{url}/#{uri}"
    now = System.monotonic_time(:second)
    time_diff = now - last_timestamp

    cond do
      count >= max_requests ->
        CaptiveRateLimiter.reset(mac_addr, reset_after)

        conn
        |> redirect(external: url)
        |> halt()

      time_diff < allowed_time_window ->
        new_count = count + 1
        CaptiveRateLimiter.increment_count(mac_addr, now, new_count)
        conn

      true ->
        CaptiveRateLimiter.increment_count(mac_addr, now, count)
        conn
    end
  end

  defp captive_options() do
    :airlink |> Application.get_env(:captive)
  end
end
