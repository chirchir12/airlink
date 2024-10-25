defmodule AirlinkWeb.PaymentController do
  use AirlinkWeb, :controller

  alias Airlink.Customers.Customer
  alias Airlink.Customers
  alias Airlink.Payments
  alias Airlink.Plans
  import Airlink.Helpers

  plug AirlinkWeb.CheckRolesPlug, ["captive_user"]
  action_fallback AirlinkWeb.FallbackController

  def create(%Plug.Conn{assigns: %{captive_data: captive_data}} = conn, %{"params" => params}) do
    params = params
            |> atomize_map_keys()
            |> Map.put(:company_id, captive_data.company_id)
            |> Map.put_new(:customer_id, captive_data.customer_id )
            |> Map.put_new(:customer_uuid, captive_data.customer_uuid)

    with {:ok, %Customer{}} <- Customers.get_customer_by_uuid(captive_data.customer_uuid),
         {:ok, params} <- Payments.validate(params),
         {:ok, plan} <- Plans.get_plan_uuid(params.plan_id),
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
