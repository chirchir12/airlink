defmodule Airlink.AccessPoints.AccessPoint do
  use Ecto.Schema
  import Ecto.Changeset
  import Airlink.Helpers

  @permitted_fields [
    :landmark,
    :mac_address,
    :name,
    :type,
    :description,
    :company_id,
    :status,
    :last_seen,
    :offline_after
  ]

  @required_fields [
    :landmark,
    :mac_address,
    :name,
    :type,
    :company_id,
    :offline_after
  ]

  schema "access_points" do
    field :landmark, :string
    field :mac_address, :string
    field :name, :string
    field :type, :string
    field :description, :string
    field :uuid, Ecto.UUID
    field :status, :string, default: "Offline"
    field :company_id, Ecto.UUID
    field :last_seen, :utc_datetime
    field :offline_after, :integer
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(access_point, attrs) do
    access_point
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> validate_format(:mac_address, ~r/^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/)
    |> unique_constraint([:mac_address, :company_id])
    |> unique_constraint(:uuid)
    |> maybe_put_uuid(:uuid)
    |> down_case()
  end

  defp down_case(changeset) do
    case get_change(changeset, :mac_address) do
      nil -> changeset
      mac -> put_change(changeset, :mac_address, mac |> String.downcase())
    end
  end
end
