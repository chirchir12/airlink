defmodule AirlinkWeb.HotspotJSON do
  alias Airlink.Hotspots.Hotspot

  @doc """
  Renders a list of hotspots.
  """
  def index(%{hotspots: hotspots}) do
    %{data: for(hotspot <- hotspots, do: data(hotspot))}
  end

  @doc """
  Renders a single hotspot.
  """
  def show(%{hotspot: hotspot}) do
    %{data: data(hotspot)}
  end

  defp data(%Hotspot{} = hotspot) do
    %{
      id: hotspot.id,
      name: hotspot.name,
      description: hotspot.description,
      latitude: hotspot.latitude,
      longitude: hotspot.longitude,
      router_id: hotspot.router_id,
      company_id: hotspot.company_id,
      landmark: hotspot.landmark,
      bridge_name: hotspot.bridge_name,
      uuid: hotspot.uuid
    }
  end
end
