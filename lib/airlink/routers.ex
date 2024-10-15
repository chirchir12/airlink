defmodule Airlink.Routers do
  alias Airlink.Routers.RouterServer

  @doc """
  Adds a new router to the cache.

  ## Examples

      iex> add_router("123e4567-e89b-12d3-a456-426614174000", %{name: "Router 1", ip: "192.168.1.1"})
      :ok

  """
  def add_router(uuid, router_info) do
    RouterServer.add_router(uuid, router_info)
  end

  @doc """
  Deletes a router from the cache.

  ## Examples

      iex> delete_router("123e4567-e89b-12d3-a456-426614174000")
      :ok

  """
  def delete_router(uuid) do
    RouterServer.delete_router(uuid)
  end

  @doc """
  Updates an existing router in the cache.

  ## Examples

      iex> update_router("123e4567-e89b-12d3-a456-426614174000", %{name: "Updated Router 1", ip: "192.168.1.2"})
      :ok

  """
  def update_router(uuid, router_info) do
    RouterServer.update_router(uuid, router_info)
  end

  @doc """
  Retrieves a router from the cache by its UUID.

  ## Examples

      iex> get_router("123e4567-e89b-12d3-a456-426614174000")
      {:ok, %{name: "Router 1", ip: "192.168.1.1"}}

      iex> get_router("non-existent-uuid")
      {:error, :not_found}

  """
  def get_router(uuid) do
    RouterServer.get_router(uuid)
  end

  def handle_router_changes(params) do
    handle_change(params)
  end

  defp handle_change(%{action: "create", router_id: router_id} = params) do
    {:ok, _} = add_router(router_id, params)
    :ok
  end

  defp handle_change(%{action: "update", router_id: router_id} = params) do
    {:ok, _} = update_router(router_id, params)
    :ok
  end

  defp handle_change(%{action: "delete", router_id: router_id}) do
    {:ok, _} = delete_router(router_id)
    :ok
  end
end
