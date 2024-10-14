defmodule AirlinkWeb.AuthJSON do
  alias Airlink.Customers.Customer

  def auth(%{data: {customer, captive}}) do
    %{
      data: %{
        customer: customer_data(customer),
        captive: captive
      }
    }
  end

  def customer_data(%Customer{} = customer) do
    %{
      username: customer.username,
      password: customer.password_hash
    }
  end
end
