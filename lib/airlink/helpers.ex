defmodule Airlink.Helpers do
  import Ecto.Changeset



  # changeset functions
  def maybe_put_uuid(%Ecto.Changeset{valid?: true} = changeset, field) do
    if changeset.data.id do
      changeset
    else
      case get_field(changeset, field) do
        nil -> changeset |> put_change(field, Ecto.UUID.generate())
        _ -> changeset
      end
    end
  end

  def maybe_put_uuid(changeset, _field), do: changeset
end
