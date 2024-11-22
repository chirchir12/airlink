defmodule Airlink.AccessPoints do
  @moduledoc """
  The AccessPoints context.
  """

  import Ecto.Query, warn: false
  alias Airlink.Repo
  alias Airlink.AccessPoints.AccessPoint

  @doc """
  Returns the list of access_points.
  """
  def list_access_points do
    Repo.all(AccessPoint)
  end

  @doc """
  Gets a single access_point.
  """
  def get_access_point(id) do
    case Repo.get(AccessPoint, id) do
      nil -> {:error, :access_point_not_found}
      access_point -> {:ok, access_point}
    end
  end

  @doc """
  Gets a single access_point by UUID.
  """
  def get_access_point_by_uuid(uuid) do
    case Repo.get_by(AccessPoint, uuid: uuid) do
      nil -> {:error, :access_point_not_found}
      access_point -> {:ok, access_point}
    end
  end

  def get_by_mac_address(mac_add, company_id) do
    query =
      from ap in AccessPoint, where: ap.company_id == ^company_id and ap.mac_address == ^mac_add

    case Repo.one(query) do
      nil -> {:error, :access_point_not_found}
      ap -> {:ok, ap}
    end
  end

  @doc """
  Creates a access_point.
  """
  def create_access_point(attrs \\ %{}) do
    %AccessPoint{}
    |> AccessPoint.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a access_point.
  """
  def update_access_point(%AccessPoint{} = access_point, attrs) do
    access_point
    |> AccessPoint.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a access_point.
  """
  def delete_access_point(%AccessPoint{} = access_point) do
    Repo.delete(access_point)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking access_point changes.
  """
  def change_access_point(%AccessPoint{} = access_point, attrs \\ %{}) do
    AccessPoint.changeset(access_point, attrs)
  end

  @doc """
  Returns the list of access_points for a specific company.
  """
  def list_company_access_points(company_id) do
    data =
      AccessPoint
      |> where([ap], ap.company_id == ^company_id)
      |> Repo.all()

    {:ok, data}
  end
end
