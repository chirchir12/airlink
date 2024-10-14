defmodule Airlink.Captive.Captive do
  use Ecto.Schema
  import Ecto.Changeset

  @permitted_field [
    :mac,
    :ip,
    :company_id,
    :link_login_only,
    :link_orig,
    :hotspot_id,
    :router_id
  ]
  @required_field [
    :mac,
    :company_id,
    :link_login_only,
    :hotspot_id,
    :router_id
  ]

  @primary_key false
  embedded_schema do
    field :mac, :string
    field :ip, :string
    field :company_id, Ecto.UUID
    field :link_login_only, :string
    field :link_orig, :string
    field :hotspot_id, Ecto.UUID
    field :routerid, Ecto.UUID
  end

  def changeset(captive, attrs) do
    captive
    |> cast(attrs, @permitted_field)
    |> validate_required(@required_field)
  end
end
