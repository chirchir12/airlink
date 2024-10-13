defmodule Airlink.Subscriptions.Subscription do
  use Ecto.Schema
  import Ecto.Changeset
  import Airlink.Helpers

  @allowed_status ["pending", "failed", "completed"]

  schema "subscriptions" do
    field :status, :string
    field :expires_at, :utc_datetime
    field :company_id, Ecto.UUID
    field :uuid, Ecto.UUID
    field :meta, :map
    belongs_to :customer, Airlink.Customers.Customer
    belongs_to :plan, Airlink.Plans.Plan

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:customer_id, :plan_id, :status, :expires_at, :company_id, :meta])
    |> validate_required([:customer_id, :plan_id, :status, :company_id])
    |> foreign_key_constraint(:customer_id)
    |> foreign_key_constraint(:plan_id)
    |> validate_status()
    |> maybe_put_uuid(:uuid)
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
