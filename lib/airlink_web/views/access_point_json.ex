defmodule AirlinkWeb.AccessPointJSON do
  alias Airlink.AccessPoints.AccessPoint

  @doc """
  Renders a list of access_points.
  """
  def index(%{access_points: access_points}) do
    %{data: for(access_point <- access_points, do: data(access_point))}
  end

  @doc """
  Renders a single access_point.
  """
  def show(%{access_point: access_point}) do
    %{data: data(access_point)}
  end

  defp data(%AccessPoint{} = access_point) do
    current_time = DateTime.utc_now()
    offline_after = access_point.offline_after

    # Calculate the offline status
    status =
      if access_point.last_seen == nil or
           DateTime.diff(current_time, access_point.last_seen) > offline_after * 60 do
        "offline"
      else
        "online"
      end

    %{
      id: access_point.id,
      uuid: access_point.uuid,
      landmark: access_point.landmark,
      mac_address: access_point.mac_address,
      name: access_point.name,
      type: access_point.type,
      description: access_point.description,
      company_id: access_point.company_id,
      status: status,
      last_seen: access_point.last_seen
    }
  end
end
