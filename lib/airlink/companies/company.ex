defmodule Airlink.Companies.Company do
  defstruct enabled: nil,
            id: nil,
            name: nil,
            address: nil,
            company_id: nil,
            email: nil,
            country: nil,
            has_payment_platform: nil,
            phone: nil,
            region: nil,
            website: nil

  def new(attrs) when is_map(attrs) do
    struct(__MODULE__, attrs)
  end
end
