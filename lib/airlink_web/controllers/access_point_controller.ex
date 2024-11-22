defmodule AirlinkWeb.AccessPointController do
  use AirlinkWeb, :controller

  alias Airlink.AccessPoints
  alias Airlink.AccessPoints.AccessPoint

  action_fallback AirlinkWeb.FallbackController

  def index(conn, %{"company_id" => company_id}) do
    access_points = AccessPoints.list_company_access_points(company_id)
    render(conn, :index, access_points: access_points)
  end

  def create(conn, %{"params" => access_point_params}) do
    with {:ok, %AccessPoint{} = access_point} <-
           AccessPoints.create_access_point(access_point_params) do
      conn
      |> put_status(:created)
      |> render(:show, access_point: access_point)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, access_point} <- AccessPoints.get_access_point(id) do
      render(conn, :show, access_point: access_point)
    end
  end

  def update(conn, %{"id" => id, "params" => access_point_params}) do
    with {:ok, access_point} <- AccessPoints.get_access_point(id),
         {:ok, %AccessPoint{} = access_point} <-
           AccessPoints.update_access_point(access_point, access_point_params) do
      render(conn, :show, access_point: access_point)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, access_point} <- AccessPoints.get_access_point(id),
         {:ok, %AccessPoint{} = access_point} <- AccessPoints.delete_access_point(access_point) do
      render(conn, :show, access_point: access_point)
    end
  end
end
