defmodule AirlinkWeb.PlanController do
  use AirlinkWeb, :controller

  alias Airlink.Plans
  alias Airlink.Plans.Plan
  alias Airlink.Hotspots
  alias Airlink.Hotspots.Hotspot
  plug AirlinkWeb.CheckRolesPlug, ["captive_user", "%", "admin", "system"]
  action_fallback AirlinkWeb.FallbackController

  def index(%Plug.Conn{assigns: %{captive_data: captive_data}} = conn, %{
        "company_id" => company_id
      }) do
    with {:ok, %Hotspot{id: hotspot_id}} <- Hotspots.get_hotspot_by_uuid(captive_data.hotspot_id),
         {:ok, plans} <- Plans.list_plans(company_id, hotspot_id) do
      conn
      |> render(:index, plans: plans)
    end
  end

  def index(%Plug.Conn{assigns: %{captive_data: captive_data}} = conn, _params) do
    with {:ok, %Hotspot{id: hotspot_id}} <- Hotspots.get_hotspot_by_uuid(captive_data.hotspot_id),
         {:ok, plans} <- Plans.list_plans(captive_data.company_id, hotspot_id) do
      conn
      |> render(:index, plans: plans)
    end
  end

  def index(conn, %{"company_id" => company_id, "hotspot_id" => hotspot_id}) do
    with {:ok, plans} <- Plans.list_plans(company_id, hotspot_id) do
      conn
      |> render(:index, plans: plans)
    end
  end

  def index(conn, %{"company_id" => company_id}) do
    with {:ok, plans} <- Plans.list_plans(company_id) do
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

  def show(conn, %{"uuid" => uuid}) do
    with {:ok, plan} <- Plans.get_plan_uuid(uuid) do
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
         {:ok, %Plan{} = plan} <- Plans.delete_plan(plan) do
      conn
      |> render(:show, plan: plan)
    end
  end
end
