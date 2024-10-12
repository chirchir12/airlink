defmodule Airlink.Customers.Customer do
  use Ecto.Schema
  import Ecto.Changeset
  import Airlink.Helpers

  @allowed_status ["active", "inactive"]

  @permitted_fields [
    :company_id,
    :username,
    :status,
    :first_name,
    :last_name,
    :email,
    :phone_number,
    :password
  ]

  @required_fields [
    :company_id,
    :username,
    :status
  ]

  schema "customers" do
    field :company_id, Ecto.UUID
    field :username, :string
    field :status, :string
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :phone_number, :string
    field :password_hash, :string
    field :customer_id, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:company_id, :username])
    |> maybe_put_uuid(:customer_id)
    |> validate_status()
  end
  defp validate_status(%Ecto.Changeset{valid?: true, changes: %{status: status}} = changeset) do
    if status in @allowed_status do
      changeset
    else
      add_error(changeset, :status, "is not supported")
    end
  end

  defp validate_status(changeset), do: changeset
end
