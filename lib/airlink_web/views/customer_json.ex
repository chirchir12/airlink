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

  def customer_fetch(%{result: result}) do
    %{data: result}
  end
end
