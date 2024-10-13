defmodule Airlink.Captive.Captive do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :routerid, Ecto.UUID
    field :mac, :string
    field :company_id, Ecto.UUID
    field :ip, :string
    field :link_orig, :string
    field :server_name, Ecto.UUID
  end

  def changeset(captive, attrs) do
    captive
    |> cast(attrs, [:routerid, :mac, :company_id, :ip, :link_orig, :server_name])
    |> validate_required([:routerid, :mac, :company_id, :ip, :link_orig, :server_name])
    |> validate_format(:ip, ~r/^(\d{1,3}\.){3}\d{1,3}$/)
  end
end
