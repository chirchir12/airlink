defmodule AirlinkWeb.CorsPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    allowed_origins = [
      "https://captive.diracloud.com",
      "http://localhost:3000",
       "https://captive.diralink.com",
    ]

    origin = get_req_header(conn, "origin") |> List.first()

    conn =
      if origin in allowed_origins do
        conn
        |> put_resp_header("access-control-allow-origin", origin)
        |> put_resp_header("access-control-allow-credentials", "true")
        |> put_resp_header("access-control-allow-methods", "GET,POST,PUT,PATCH,DELETE,OPTIONS")
        |> put_resp_header(
          "access-control-allow-headers",
          "Authorization,Content-Type,Accept,Origin,User-Agent,Cookie,Set-Cookie,x-csrf-token"
        )
        |> put_resp_header("access-control-expose-headers", "Authorization,Set-Cookie")
        |> put_resp_header("access-control-max-age", "86400")
      else
        conn
      end

    # Handle OPTIONS request
    case conn.method do
      "OPTIONS" ->
        conn
        |> put_resp_header("content-length", "0")
        |> send_resp(:no_content, "")
        |> halt()

      _ ->
        conn
    end
  end
end
