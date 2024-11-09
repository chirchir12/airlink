defmodule Airlink.Customers.Customer do
  use Ecto.Schema
  import Ecto.Changeset
  import Airlink.Helpers

  @allowed_status ["active", "inactive"]

  @permitted_fields [
    :id,
    :uuid,
    :username,
    :password_hash,
    :company_id,
    :status,
    :first_name,
    :last_name,
    :email,
    :phone_number,
    :inserted_at,
    :updated_at
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
    field :uuid, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(customer, attrs) do
    customer
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:company_id, :username])
    |> maybe_put_uuid(:uuid)
    |> validate_status()
    |> maybe_generate_password_hash()
    |> unique_constraint(:id, name: "customers_pkey")
  end

  def update_status_changeset(customer, attrs) do
    customer
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end

  defp validate_status(%Ecto.Changeset{valid?: true, changes: %{status: status}} = changeset) do
    if status in @allowed_status do
      changeset
    else
      add_error(changeset, :status, "is not supported")
    end
  end

  defp validate_status(changeset), do: changeset

  defp maybe_generate_password_hash(%Ecto.Changeset{valid?: true} = changeset) do
    case get_change(changeset, :password_hash) do
      nil ->
        random_password = generate_random_password(8)
        put_change(changeset, :password_hash, random_password)

      _ ->
        changeset
    end
  end

  defp maybe_generate_password_hash(changeset), do: changeset

  defp generate_random_password(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
