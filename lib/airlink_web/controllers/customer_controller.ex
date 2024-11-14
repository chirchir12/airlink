defmodule AirlinkWeb.CustomerController do
  use AirlinkWeb, :controller

  alias Airlink.Customers
  import Airlink.Helpers

  plug AirlinkWeb.CheckRolesPlug, [
    "captive_user",
    "tenant",
    "%",
    "admin",
    "tenant.individual",
    "system"
  ]

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
         {:ok, customer} <- Customers.delete_customer(customer) do
      conn
      |> put_status(:ok)
      |> render(:show, customer: customer)
    end
  end

  # reports
  def customer_fetch(conn, %{"company_id" => company_id} = params) do
    with {:ok, result} <- Customers.customer_report(company_id, params |> atomize_map_keys()) do
      conn
      |> render(:customer_fetch, result: result)
    end
  end
end
