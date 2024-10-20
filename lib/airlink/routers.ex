defmodule Airlink.Routers do
  alias Airlink.Routers.RouterServer
  alias Airlink.Routers.Router

  @doc """
  Adds a new router to the cache.

  ## Examples

      iex> add_router(router_id, %{name: "Router 1", ip: "192.168.1.1"})
      :ok

  """
  def add_router(router_id, router_info) do
    RouterServer.add_router(router_id, Router.new(router_info))
  end

  @doc """
  Deletes a router from the cache.

  ## Examples

      iex> delete_router(router_id)
      :ok

  """
  def delete_router(router_id) do
    RouterServer.delete_router(router_id)
  end

  @doc """
  Updates an existing router in the cache.

  ## Examples

      iex> update_router(router_id, %{name: "Updated Router 1", ip: "192.168.1.2"})
      :ok

  """
  def update_router(router_id, router_info) do
    RouterServer.update_router(router_id, Router.new(router_info))
  end

  @doc """
  Retrieves a router from the cache by its UUID.

  ## Examples

      iex> get_router(router_id)
      {:ok, %Router{}

      iex> get_router("non-existent-uuid")
      {:error, :not_found}

  """
  def get_router(router_id) do
    RouterServer.get_router(router_id)
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
