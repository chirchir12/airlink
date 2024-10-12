defmodule AirlinkWeb.PlanController do
  use AirlinkWeb, :controller

  alias Airlink.Plans
  alias Airlink.Plans.Plan

  action_fallback AirlinkWeb.FallbackController

  def index(conn, _params) do
    with {:ok, plans}  <- Plans.list_plans() do
      conn
      |> render(:index, plans: plans)
    end
  end

  def create(conn, %{"params" => plan_params}) do
    with {:ok, %Plan{} = plan} <- Plans.create_plan(plan_params) do
      conn
      |> put_status(:created)
      |> render(:show, plan: plan)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, plan} <- Plans.get_plan_id(id) do
      conn
      |> render(:show, plan: plan)
    end
  end

  def update(conn, %{"id" => id, "params" => plan_params}) do
    with {:ok, plan} <- Plans.get_plan_id(id),
    {:ok, %Plan{} = plan} <- Plans.update_plan(plan, plan_params) do
      conn
      |> render(:show, plan: plan)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, plan} <- Plans.get_plan_id(id),
    {:ok, %Plan{}} <- Plans.delete_plan(plan) do
      send_resp(conn, :no_content, "")
    end
  end
end
