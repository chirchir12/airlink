defmodule Airlink.Hotspots.Hotspot do
  use Ecto.Schema
  import Ecto.Changeset
  import Airlink.Helpers

  @permitted_fields [
    :name,
    :description,
    :bridge_name,
    :landmark,
    :company_id,
    :latitude,
    :longitude,
    :router_id
  ]

  @required_fields [
    :name,
    :description,
    :bridge_name,
    :landmark,
    :company_id,
    :router_id
  ]

  schema "hotspots" do
    field :name, :string
    field :description, :string
    field :bridge_name, :string
    field :landmark, :string
    field :uuid, Ecto.UUID
    field :company_id, Ecto.UUID
    field :router_id, Ecto.UUID
    field :latitude, :float
    field :longitude, :float
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(hotspot, attrs) do
    hotspot
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> maybe_put_uuid(:uuid)
  end
end
