defmodule Airlink.CustomersTest do
  use Airlink.DataCase

  alias Airlink.Customers
  alias Airlink.Customers.Customer

  describe "customers" do
    @valid_attrs %{username: "username", status: "inactive", company_id: Ecto.UUID.generate()}
    @update_attrs %{first_name: "Jane Doe", email: "jane@example.com"}
    @invalid_attrs %{name: nil, email: nil}

    def customer_fixture(attrs \\ %{}) do
      {:ok, customer} =
        attrs
        |> Enum.into(%{
          username: "username",
          company_id: Ecto.UUID.generate(),
          status: "inactive"
        })
        |> Customers.create_customer()

      customer
    end

    test "list_customers/0 returns all customers" do
      customer = customer_fixture()
      assert Customers.list_customers() == [customer]
    end

    test "get_customer_by_id/1 returns the customer with given id" do
      customer = customer_fixture()
      assert {:ok, %Customer{} = fetched_customer} = Customers.get_customer_by_id(customer.id)
      assert fetched_customer.id == customer.id
    end

    test "get_customer_by_id/1 returns error for non-existent id" do
      assert {:error, :customer_not_found} = Customers.get_customer_by_id(123_456)
    end

    test "get_customer_by_uuid/1 returns the customer with given uuid" do
      customer = customer_fixture()

      assert {:ok, %Customer{} = fetched_customer} =
               Customers.get_customer_by_uuid(customer.customer_id)

      assert fetched_customer.uuid == customer.customer_id
    end

    test "get_customer_by_uuid/1 returns error for non-existent uuid" do
      assert {:error, :customer_not_found} = Customers.get_customer_by_uuid(Ecto.UUID.generate())
    end

    test "create_customer/1 with valid data creates a customer" do
      assert {:ok, %Customer{} = customer} = Customers.create_customer(@valid_attrs)
      assert customer.username == "username"
    end

    test "create_customer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Customers.create_customer(@invalid_attrs)
    end

    test "update_customer/2 with valid data updates the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{} = customer} = Customers.update_customer(customer, @update_attrs)
      assert customer.first_name == "Jane Doe"
      assert customer.email == "jane@example.com"
    end

    test "update_customer/2 with invalid data returns error changeset" do
      customer = customer_fixture()
      assert {:error, %Ecto.Changeset{}} = Customers.update_customer(customer, @invalid_attrs)
      assert {:ok, ^customer} = Customers.get_customer_by_id(customer.id)
    end

    test "delete_customer/1 deletes the customer" do
      customer = customer_fixture()
      assert {:ok, %Customer{}} = Customers.delete_customer(customer)
      assert {:error, :customer_not_found} = Customers.get_customer_by_id(customer.id)
    end

    test "change_customer/1 returns a customer changeset" do
      customer = customer_fixture()
      assert %Ecto.Changeset{} = Customers.change_customer(customer)
    end
  end
end
