defmodule AirlinkWeb.CustomerJSON do
  alias Airlink.Customers.Customer

  def index(%{customers: customers}) do
    %{data: for(customer <- customers, do: data(customer))}
  end

  def show(%{customer: customer}) do
    %{
      data: data(customer)
    }
  end

  def data(%Customer{} = customer) do
    %{
      id: customer.id,
      customer_id: customer.customer_id,
      company_id: customer.company_id,
      username: customer.username,
      phone: customer.phone_number,
      status: customer.status,
      email: customer.email,
      first_name: customer.first_name,
      last_name: customer.last_name
    }
  end
end
