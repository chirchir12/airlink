defmodule AirlinkWeb.PaymentController do
  use AirlinkWeb, :controller

  alias Airlink.Payments
  alias Airlink.Plans
  alias Airlink.Captive
  action_fallback AirlinkWeb.FallbackController

  def create(conn, %{"params" => params}) do
    with {:ok, params} <- Payments.validate(params),
         {:ok, {_customer, _captive_entry}} <- Captive.get_entry(params.customer_id),
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
