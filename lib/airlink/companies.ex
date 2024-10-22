defmodule Airlink.Companies do
  alias Airlink.Companies.CompanyServer
  alias Airlink.Companies.Company

  @doc """
  Adds a new company to the CompanyServer.

  ## Examples

      iex> add_company("123e4567-e89b-12d3-a456-426614174000", %{name: "Acme Corp"})
      :ok

  """
  def add_company(uuid, company_info) do
    CompanyServer.add_company(uuid, Company.new(company_info))
  end

  @doc """
  Deletes a company from the CompanyServer.

  ## Examples

      iex> delete_company("123e4567-e89b-12d3-a456-426614174000")
      :ok

  """
  def delete_company(uuid) do
    CompanyServer.delete_company(uuid)
  end

  @doc """
  Updates an existing company in the CompanyServer.

  ## Examples

      iex> update_company("123e4567-e89b-12d3-a456-426614174000", %{name: "Updated Corp"})
      :ok

  """
  def update_company(uuid, company_info) do
    CompanyServer.update_company(uuid, Company.new(company_info))
  end

  @doc """
  Retrieves a company from the CompanyServer.

  ## Examples

      iex> get_company("123e4567-e89b-12d3-a456-426614174000")
      {:ok, %{name: "Acme Corp"}}

      iex> get_company("non-existent-uuid")
      {:error, :not_found}

  """
  def get_company(uuid) do
    CompanyServer.get_company(uuid)
  end

  def handle_company_changes(params) do
    handle_change(params)
  end

  defp handle_change(%{action: "create", company_id: company_id} = params) do
    add_company(company_id, params)
    :ok
  end

  defp handle_change(%{action: "delete", company_id: company_id}) do
    delete_company(company_id)
    :ok
  end

  defp handle_change(%{action: "update", company_id: company_id} = params) do
    update_company(company_id, params)
    :ok
  end
end
