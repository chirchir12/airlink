defmodule Airlink.Customers do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Airlink.Repo

  alias Airlink.Customers.Customer

  def customer_report(company_id, params) do
    page_number = Map.get(params, :page_number) || 1
    page_size = Map.get(params, :page_size) || 10
    {:ok, company_id} = Ecto.UUID.dump(company_id)

    sql = """
      SELECT
        c.id,
        c.uuid::text,
        c.username,
        c.phone_number,
        c.status,
        c.inserted_at AS joined_on,
        s.expires_at,
        p.name as plan_name,
        h.name as hotspot_name
      FROM customers c
      LEFT JOIN LATERAL(
        SELECT s.* FROM subscriptions s
        WHERE s.customer_id = c.id
        ORDER BY s.id DESC limit 1
      ) s ON true
      LEFT JOIN plans p on p.id = s.plan_id
      LEFT JOIN hotspots h ON p.hotspot_id = h.id
       WHERE c.company_id = $1
      ORDER BY s.expires_at DESC NULLS LAST, c.id DESC
      LIMIT #{page_size}
      OFFSET #{(page_number - 1) * page_size}
    """

    query = from c in Customer, where: c.company_id == ^company_id

    total_count =
      query
      |> Repo.aggregate(:count, :id)

    result =
      case Repo.query(sql, [company_id]) do
        {:ok, %{rows: rows, columns: columns}} ->
          results =
            Enum.map(rows, fn row ->
              Enum.zip(columns, row) |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
            end)

          {:ok, results}

        {:error, error} ->
          {:error, error}
      end

    with {:ok, result} <- result do
      {:ok,
       %{
         data: result,
         page_number: page_number,
         page_size: page_size,
         total_count: total_count,
         total_pages: ceil(total_count / page_size)
       }}
    end
  end

  def list_customers do
    {:ok, Repo.all(Customer)}
  end

  @doc """
  Gets a single customer.

  Raises `Ecto.NoResultsError` if the Customer does not exist.

  ## Examples

      iex> get_customer!(123)
      %Customer{}

      iex> get_customer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_customer_by_id(id) do
    case Repo.get(Customer, id) do
      nil -> {:error, :customer_not_found}
      customer -> {:ok, customer}
    end
  end

  def get_customer_by_uuid(uuid) do
    case Repo.get_by(Customer, uuid: uuid) do
      nil ->
        {:error, :customer_not_found}

      customer ->
        {:ok, customer}
    end
  end

  def get_or_create_customer(username, company_id) do
    case Repo.get_by(Customer, username: username, company_id: company_id) do
      nil ->
        create_customer(%{username: username, company_id: company_id, status: "inactive"})

      customer ->
        {:ok, customer}
    end
  end

  @doc """
  Creates a customer.

  ## Examples

      iex> create_customer(%{field: value})
      {:ok, %Customer{}}

      iex> create_customer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_customer(attrs \\ %{}) do
    %Customer{}
    |> Customer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a customer.

  ## Examples

      iex> update_customer(customer, %{field: new_value})
      {:ok, %Customer{}}

      iex> update_customer(customer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_customer(%Customer{} = customer, attrs) do
    customer
    |> Customer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a customer.

  ## Examples

      iex> delete_customer(customer)
      {:ok, %Customer{}}

      iex> delete_customer(customer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_customer(%Customer{} = customer) do
    Repo.delete(customer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking customer changes.

  ## Examples

      iex> change_customer(customer)
      %Ecto.Changeset{data: %Customer{}}

  """
  def change_customer(%Customer{} = customer, attrs \\ %{}) do
    Customer.changeset(customer, attrs)
  end
end
