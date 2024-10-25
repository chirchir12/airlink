defmodule AirlinkWeb.CompanyController do
  use AirlinkWeb, :controller

  alias Airlink.Companies
  plug AirlinkWeb.CheckRolesPlug, ["captive_user"]
  action_fallback AirlinkWeb.FallbackController

  def show(%Plug.Conn{assigns: %{captive_data: captive_data}} = conn, _params) do
    with {:ok, company} <- Companies.get_company(captive_data.company_id) do
      conn
      |> put_status(:ok)
      |> render(:show, company: company)
    end
  end
end
