defmodule Airlink.Accounting do
  alias Airlink.Accounting.Accounting
  alias Airlink.Repo
  require Logger

  def create(attrs) do
    %Accounting{}
    |> Accounting.changeset(attrs)
    |> Repo.insert()
  end

  def update(accounting, attrs) do
    accounting
    |> Accounting.changeset(attrs)
    |> Repo.insert()
  end

  def get_by_session_id(session_id) do
    case Repo.get_by(Accounting, acct_unique_session_id: session_id) do
      nil ->
        {:error, :session_not_found}

      accounting ->
        {:ok, accounting}
    end
  end

  def handle_accounting_data(%{subscription_id: sub_id} = params) when is_nil(sub_id) do
    Logger.warning("Invalid accounting data: #{inspect(params)}")
    {:error, :subscription_not_found}
  end

  def handle_accounting_data(%{acct_unique_session_id: session_id} = params) do
    with {:ok, accounting} <- get_by_session_id(session_id) do
      update(accounting, params)
    else
      {:error, :session_not_found} ->
        create(params)
    end
  end

  def handle_accounting_data(params) do
    Logger.error("Invalid accounting data: #{inspect(params)}")
    {:error, :invalid_accounting_data}
  end
end
