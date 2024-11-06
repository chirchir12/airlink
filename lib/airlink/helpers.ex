defmodule Airlink.Helpers do
  import Ecto.Changeset

  # changeset functions
  def maybe_put_uuid(%Ecto.Changeset{valid?: true} = changeset, field) do
    cond do
      # Check if the changeset already has an ID
      get_field(changeset, :id) ->
        changeset

      # Check if the specified field is already set
      get_field(changeset, field) ->
        changeset

      # If neither ID nor the field is set, generate a new UUID
      true ->
        put_change(changeset, field, Ecto.UUID.generate())
    end
  end

  # Handle invalid changesets
  def maybe_put_uuid(changeset, _field), do: changeset

  def kw_to_map(data) when is_list(data) do
    if Keyword.keyword?(data) do
      data
      |> Enum.map(fn
        {key, value} when is_list(value) -> {key, kw_to_map(value)}
        {key, value} -> {key, value}
        other -> other
      end)
      |> Enum.into(%{})
    else
      data
    end
  end

  def kw_to_map(data), do: data

  def get_config(app) do
    :airlink
    |> Application.get_env(app)
    |> kw_to_map()
  end

  def basic_auth(config) do
    credentials = Base.encode64("#{config.username}:#{config.password}")
    [{"Authorization", "Basic #{credentials}"}]
  end

  def bearer_auth(token) do
    [{"Authorization", "Bearer #{token}"}]
  end

  def atomize_map_keys(data) when is_list(data) do
    data
    |> Enum.map(&atomize_map_keys/1)
  end

  def atomize_map_keys(map) when is_map(map) do
    map
    |> Enum.map(fn {k, v} -> {atomize_key(k), atomize_value(v)} end)
    |> Enum.into(%{})
  end

  def normalize_mac(value) when is_binary(value) do
    case String.match?(value, ~r/^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$/) do
      true -> String.upcase(value)
      false -> value
    end
  end

  def normalize_mac(value), do: value

  def process_message(params, func) when is_list(params) do
    params
    |> Enum.map(&atomize_map_keys/1)
    |> Enum.each(&process_message(&1, func))
  end

  def process_message(%{sender: "airlink"}, _func) do
    :ok
  end

  def process_message(params, func) when is_function(func, 1) do
    func.(params)
  end

  defp atomize_key(key) when is_binary(key), do: String.to_atom(key)
  defp atomize_key(key) when is_atom(key), do: key

  defp atomize_value(value) when is_map(value), do: atomize_map_keys(value)
  defp atomize_value(value) when is_list(value), do: Enum.map(value, &atomize_value/1)
  defp atomize_value(value), do: value
end
