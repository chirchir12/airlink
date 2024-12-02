defmodule Airlink.Subscriptions.Reactivate do
  use Ecto.Schema
  import Ecto.Changeset

  @allowed_actions ["full", "remaining"]

  embedded_schema do
    field :action, :string
    field :time_used_in_sec, :integer
    field :current_sub_id, Ecto.UUID
  end

  def changeset(t, attrs) do
    t
    |> cast(attrs, [:action, :time_used_in_sec, :current_sub_id])
    |> validate_required([:action, :time_used_in_sec, :current_sub_id])
    |> validate_action()
  end

  defp validate_action(%Ecto.Changeset{valid?: true, changes: %{action: action}} = changeset) do
    if action in @allowed_actions do
      changeset
    else
      add_error(changeset, :action, "is not supported")
    end
  end

  defp validate_action(changeset), do: changeset
end
