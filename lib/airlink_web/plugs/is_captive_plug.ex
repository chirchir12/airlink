defmodule AirlinkWeb.IsCaptivePlug do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _) do
    conn
    |> assign(:is_captive, true)
  end
end
