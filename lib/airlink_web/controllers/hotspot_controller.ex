defmodule AirlinkWeb.HotspotController do
  use AirlinkWeb, :controller

  alias Airlink.Hotspots
  alias Airlink.Hotspots.Hotspot
  plug AirlinkWeb.CheckRolesPlug, ["%", "admin", "system"]
  action_fallback AirlinkWeb.FallbackController

  def index(conn, %{"company_id" => company_id}) do
    with {:ok, hotspots} <- Hotspots.list_hotspots(company_id) do
      conn
      |> render(:index, hotspots: hotspots)
    end
  end

  def create(conn, %{"params" => params}) do
    with {:ok, %Hotspot{} = hotspot} <- Hotspots.create_hotspot(params) do
      conn
      |> put_status(:created)
      |> render(:show, hotspot: hotspot)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, hotspot} <- Hotspots.get_hotspot_by_id(id) do
      conn
      |> render(:show, hotspot: hotspot)
    end
  end

  def update(conn, %{"id" => id, "params" => hotspot_params}) do
    with {:ok, hotspot} <- Hotspots.get_hotspot_by_id(id),
         {:ok, %Hotspot{} = hotspot} <- Hotspots.update_hotspot(hotspot, hotspot_params) do
      conn
      |> render(:show, hotspot: hotspot)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, hotspot} <- Hotspots.get_hotspot_by_id(id),
         {:ok, %Hotspot{}} <- Hotspots.delete_hotspot(hotspot) do
      send_resp(conn, :no_content, "")
    end
  end
end
