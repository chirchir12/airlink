defmodule AirlinkWeb.CustomerController do
  use AirlinkWeb, :controller

  alias Airlink.Customers
  plug AirlinkWeb.CheckRolesPlug, ["captive_user", "tenant", "%", "admin", "tenant.individual"]
  action_fallback AirlinkWeb.FallbackController

  def index(conn, _params) do
    customers = Customers.list_customers()
    render(conn, :index, customers: customers)
  end

  def create(conn, %{"params" => params}) do
    with {:ok, customer} <- Customers.create_customer(params) do
      conn
      |> put_status(:created)
      |> render(:show, customer: customer)
    end
  end

  def show(%Plug.Conn{assigns: %{captive_data: captive_data}} = conn, _params) do
    with {:ok, customer} <- Customers.get_customer_by_uuid(captive_data.customer_id) do
      data = {customer, captive_data}

      conn
      |> put_status(:ok)
      |> render(:show, data: data)
    end
  end

  def show(conn, %{"id" => id}) do
    customer = Customers.get_customer_by_id(id)

    conn
    |> put_status(:ok)
    |> render(:show, customer: customer)
  end

  def update(conn, %{"id" => id, "params" => params}) do
    with {:ok, customer} <- Customers.get_customer_by_id(id),
         {:ok, updated_customer} <- Customers.update_customer(customer, params) do
      conn
      |> put_status(:ok)
      |> render(:show, customer: updated_customer)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, customer} <- Customers.get_customer_by_id(id),
         {:ok, _customer} <- Customers.delete_customer(customer) do
      send_resp(conn, :no_content, "")
    end
  end
end
