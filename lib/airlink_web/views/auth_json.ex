defmodule AirlinkWeb.AuthJSON do
  alias Airlink.Customers.Customer

  def show(%{data: {customer, captive_data}}) do
    %{
      data: %{
        customer: data(customer),
        captive: captive_data
      }
    }
  end

  def data(%Customer{} = customer) do
    %{
      id: customer.id,
      customer_id: customer.uuid,
      company_id: customer.company_id,
      username: customer.username,
      phone: customer.phone_number,
      status: customer.status,
      email: customer.email,
      first_name: customer.first_name,
      last_name: customer.last_name,
      hash: customer.password_hash
    }
  end
end
