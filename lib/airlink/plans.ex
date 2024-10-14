defmodule Airlink.Plans do
  @moduledoc """
  The Plans context.
  """

  import Ecto.Query, warn: false
  alias Airlink.Repo

  alias Airlink.Plans.Plan

  @doc """
  Returns the list of plans.

  ## Examples

      iex> list_plans()
      [%Plan{}, ...]

  """
  def list_plans do
    {:ok, Repo.all(Plan)}
  end

  @doc """
  Gets a single plan.

  Raises `Ecto.NoResultsError` if the Plan does not exist.

  ## Examples

      iex> get_plan!(123)
      %Plan{}

      iex> get_plan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_plan_id(id) do
    case Repo.get(Plan, id) do
      nil -> {:error, :plan_not_found}
      plan -> {:ok, plan}
    end
  end

  def get_plan_uuid(uuid) do
    case Repo.get(Plan, uuid: uuid) do
      nil -> {:error, :plan_not_found}
      plan -> {:ok, plan}
    end
  end

  @doc """
  Creates a plan.

  ## Examples

      iex> create_plan(%{field: value})
      {:ok, %Plan{}}

      iex> create_plan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_plan(attrs \\ %{}) do
    %Plan{}
    |> Plan.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a plan.

  ## Examples

      iex> update_plan(plan, %{field: new_value})
      {:ok, %Plan{}}

      iex> update_plan(plan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_plan(%Plan{} = plan, attrs) do
    plan
    |> Plan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a plan.

  ## Examples

      iex> delete_plan(plan)
      {:ok, %Plan{}}

      iex> delete_plan(plan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_plan(%Plan{} = plan) do
    Repo.delete(plan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking plan changes.

  ## Examples

      iex> change_plan(plan)
      %Ecto.Changeset{data: %Plan{}}

  """
  def change_plan(%Plan{} = plan, attrs \\ %{}) do
    Plan.changeset(plan, attrs)
  end

  def calculate_duration_mins(%Plan{duration: duration, time_unit: unit}) do
    calculate_duration(duration, unit)
  end

  defp calculate_duration(duration, unit)

  defp calculate_duration(duration, "minute"), do: duration
  defp calculate_duration(duration, "hour"), do: duration * 60

  defp calculate_duration(duration, "day"), do: duration * 24 * 60
end
