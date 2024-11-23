defmodule Airlink.Hotspots.Hotspot do
  use Ecto.Schema
  import Ecto.Changeset
  import Airlink.Helpers

  @permitted_fields [
    :id,
    :uuid,
    :name,
    :description,
    :bridge_name,
    :landmark,
    :company_id,
    :latitude,
    :longitude,
    :router_id,
    :inserted_at,
    :updated_at,
    :status
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
    field :status, :string, default: "inactive"
    timestamps(type: :utc_datetime)

    # relationship
    has_many :plans, Airlink.Plans.Plan
  end

  @doc false
  def changeset(hotspot, attrs) do
    hotspot
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:name, :company_id, :router_id])
    |> maybe_put_uuid(:uuid)
    |> unique_constraint(:id, name: "hotspots_pkey")
  end
end
