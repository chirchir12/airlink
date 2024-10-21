defmodule Airlink.Payments.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :customer_id, Ecto.UUID
    field :company_id, Ecto.UUID
    field :plan_id, Ecto.UUID
    field :phone_number, :string
  end

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:customer_id, :company_id, :plan_id, :phone_number])
    |> validate_required([:customer_id, :company_id, :plan_id, :phone_number])
    |> validate_mobile_number(:phone_number)
  end

  ## validate mobile number
  def validate_mobile_number(changeset, field) do
    validate_change(changeset, field, fn _, value ->
      case is_valid_mobile_number?(value) do
        true -> []
        false -> [{field, "must be exactly 13 digits"}]
      end
    end)
  end

  defp is_valid_mobile_number?(mobile_number) do
    Regex.match?(~r/^\d{12}$/, mobile_number)
  end
end
