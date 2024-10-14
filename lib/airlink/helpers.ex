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

  def kw_to_map(data) when is_list(data) do
    data
    |> Enum.map(fn
      {key, value} when is_list(value) -> {key, kw_to_map(value)}
      {key, value} -> {key, value}
      other -> other
    end)
    |> Enum.into(%{})
  end

  def kw_to_map(data), do: data
end
