defmodule AirlinkWeb.CompanyJSON do
  alias Airlink.Companies.Company

  def show(%{company: company}) do
    %{
      data: data(company)
    }
  end

  defp data(%Company{} = company) do
    %{
      enabled: company.enabled,
      id: company.id,
      name: company.name,
      address: company.address,
      company_id: company.company_id,
      email: company.email,
      country: company.country,
      phone: company.phone,
      website: company.website
    }
  end
end
