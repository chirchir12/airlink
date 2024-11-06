defmodule Airlink.Plans.Plan do
  use Ecto.Schema
  import Ecto.Changeset
  import Airlink.Helpers

  @valid_time_unit ["minute", "hour", "day", "week", "month"]
  @valid_bundle_unit ["MB", "GB"]

  @permitted_field [
    :id,
    :uuid,
    :name,
    :description,
    :duration,
    :time_unit,
    :upload_speed,
    :download_speed,
    :speed_unit,
    :bundle_size,
    :bundle_unit,
    :price,
    :currency,
    :company_id,
    :hotspot_id,
    :inserted_at,
    :updated_at
  ]

  @required_field [
    :name,
    :description,
    :duration,
    :time_unit,
    :upload_speed,
    :download_speed,
    :bundle_size,
    :bundle_unit,
    :price,
    :currency,
    :company_id,
    :hotspot_id
  ]

  schema "plans" do
    field :uuid, Ecto.UUID
    field :name, :string
    field :description, :string

    field :duration, :integer
    field :time_unit, :string

    field :upload_speed, :integer
    field :download_speed, :integer
    field :speed_unit, :string, default: "MBps"

    field :bundle_size, :integer
    field :bundle_unit, :string

    field :price, :decimal
    field :currency, :string
    field :company_id, Ecto.UUID
    belongs_to :hotspot, Airlink.Hotspots.Hotspot

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(plan, attrs) do
    plan
    |> cast(attrs, @permitted_field)
    |> validate_required(@required_field)
    |> unique_constraint([:name, :company_id, :hotspot_id])
    |> maybe_put_uuid(:uuid)
    |> validate_time_unit()
    |> validate_bundle_unit()
    |> validate_name()
    |> unique_constraint(:id, name: "plans_pkey")
  end

  defp validate_time_unit(
         %Ecto.Changeset{valid?: true, changes: %{time_unit: time_unit}} = changeset
       ) do
    if time_unit in @valid_time_unit do
      changeset
    else
      add_error(changeset, :time_unit, "is not supported")
    end
  end

  defp validate_time_unit(changeset), do: changeset

  defp validate_bundle_unit(
         %Ecto.Changeset{valid?: true, changes: %{bundle_unit: bundle_unit}} = changeset
       ) do
    if bundle_unit in @valid_bundle_unit do
      changeset
    else
      add_error(changeset, :bundle_unit, "is not supported")
    end
  end

  defp validate_bundle_unit(changeset), do: changeset

  defp validate_name(%Ecto.Changeset{valid?: true, changes: %{name: name}} = changeset) do
    downcased_name = String.downcase(name)

    if String.match?(downcased_name, ~r/^\S*$/) do
      put_change(changeset, :name, downcased_name)
    else
      add_error(changeset, :name, "must not contain spaces")
    end
  end

  defp validate_name(changeset), do: changeset
end
