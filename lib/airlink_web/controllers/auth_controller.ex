defmodule AirlinkWeb.AuthController do
  use AirlinkWeb, :controller
  # alias Airlink.Captive
  alias Airlink.Customers
  plug AirlinkWeb.CheckRolesPlug, ["captive_user"]

  action_fallback AirlinkWeb.FallbackController

  def show(%Plug.Conn{assigns: %{captive_data: captive_data}} = conn, _params) do
    with {:ok, customer} <- Customers.get_customer_by_uuid(captive_data.customer_uuid) do
      data = {customer, captive_data}
      # delete the cookie to save memory
      # Captive.delete_entry(captive_data.cookie)

      conn
      |> put_status(:ok)
      |> render(:show, data: data)
    end
  end
end
