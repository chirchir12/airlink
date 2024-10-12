defmodule Airlink.Hotspots do
  @moduledoc """
  The Hotspots context.
  """

  import Ecto.Query, warn: false
  alias Airlink.Repo

  alias Airlink.Hotspots.Hotspot

  @doc """
  Returns the list of hotspots.

  ## Examples

      iex> list_hotspots()
      [%Hotspot{}, ...]

  """
  def list_hotspots do
    {:ok, Repo.all(Hotspot)}
  end


  def get_hotspot_by_id(id) do
    case  Repo.get(Hotspot, id) do
      nil -> {:error, :hotspot_not_found}
      hotspot -> {:ok, hotspot}
    end
  end

  def get_hotspot_by_uuid(uuid) do
    case  Repo.get(Hotspot, uuid: uuid) do
      nil -> {:error, :hotspot_not_found}
      hotspot -> {:ok, hotspot}
    end
  end

  @doc """
  Creates a hotspot.

  ## Examples

      iex> create_hotspot(%{field: value})
      {:ok, %Hotspot{}}

      iex> create_hotspot(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hotspot(attrs \\ %{}) do
    %Hotspot{}
    |> Hotspot.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a hotspot.

  ## Examples

      iex> update_hotspot(hotspot, %{field: new_value})
      {:ok, %Hotspot{}}

      iex> update_hotspot(hotspot, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_hotspot(%Hotspot{} = hotspot, attrs) do
    hotspot
    |> Hotspot.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a hotspot.

  ## Examples

      iex> delete_hotspot(hotspot)
      {:ok, %Hotspot{}}

      iex> delete_hotspot(hotspot)
      {:error, %Ecto.Changeset{}}

  """
  def delete_hotspot(%Hotspot{} = hotspot) do
    Repo.delete(hotspot)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking hotspot changes.

  ## Examples

      iex> change_hotspot(hotspot)
      %Ecto.Changeset{data: %Hotspot{}}

  """
  def change_hotspot(%Hotspot{} = hotspot, attrs \\ %{}) do
    Hotspot.changeset(hotspot, attrs)
  end
end
