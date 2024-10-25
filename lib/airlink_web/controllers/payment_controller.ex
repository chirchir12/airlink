defmodule AirlinkWeb.PaymentController do
  use AirlinkWeb, :controller

  alias Airlink.Customers.Customer
  alias Airlink.Customers
  alias Airlink.Payments
  alias Airlink.Plans

  plug AirlinkWeb.CheckRolesPlug, ["captive_user"]
  action_fallback AirlinkWeb.FallbackController

  def create(conn, %{"params" => params}) do
    with customer_uuid = params |> Map.get("customer_id"),
         {:ok, %Customer{id: customer_id}} <- Customers.get_customer_by_uuid(customer_uuid),
         {:ok, params} <- Payments.validate(params),
         params <- params |> Map.put(:customer_id, customer_id),
         {:ok, plan} <- Plans.get_plan_uuid(params.plan_id),
         params <- params |> Map.put_new(:customer_uuid, customer_uuid),
         {:ok, subscription} <- Payments.create(plan, params) do
      conn
      |> put_status(:accepted)
      |> render(:show, subscription: subscription)
    end
  end

  def show(conn, %{"ref_id" => subscription_uuid}) do
    with {:ok, subscription} <- Payments.check_status(subscription_uuid) do
      conn
      |> render(:show, subscription: subscription)
    end
  end
end
