defmodule Airlink.Customers do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Airlink.Repo
  import Airlink.Helpers

  alias Airlink.Customers.Customer

  def customer_report(company_id, params) do
    page_number = (Map.get(params, :page_number) || "1") |> String.to_integer()
    page_size = (Map.get(params, :page_size) || "10") |> String.to_integer()
    phone_number = Map.get(params, :phone_number) || nil
    IO.inspect(params)

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
        h.name as hotspot_name,
        a.acct_session_time as time_used,
        sa.updated_at AS last_seen,
        COALESCE(a.acct_input_octets, 0) as input_octets,
        COALESCE(a.acct_output_octets, 0) as output_octets,
        COALESCE(a.acct_input_gigawords, 0) as input_gigawords,
        COALESCE(a.acct_output_gigawords, 0) as output_gigawords,
        0 AS uploaded_data,
        0 AS downloaded_data,
        0 as total_data
      FROM customers c
      LEFT JOIN LATERAL(
        SELECT s.* FROM subscriptions s
        WHERE s.customer_id = c.id
        ORDER BY s.id DESC limit 1
      ) s ON true
      LEFT JOIN LATERAL(
        SELECT updated_at FROM accounting a
        WHERE a.subscription_id = s.uuid
        ORDER BY a.id DESC limit 1
      ) sa ON true

      LEFT JOIN LATERAL(
        SELECT
          SUM(acct_session_time) AS acct_session_time,
          SUM(acct_input_octets) AS acct_input_octets,
          SUM(acct_output_octets) AS acct_output_octets,
          SUM(acct_input_gigawords) AS acct_input_gigawords,
          SUM(acct_output_gigawords) AS acct_output_gigawords
        FROM accounting a
        WHERE a.subscription_id = s.uuid
      ) a ON true
      LEFT JOIN plans p on p.id = s.plan_id
      LEFT JOIN hotspots h ON p.hotspot_id = h.id
       WHERE c.company_id = $1
       #{if is_nil(phone_number), do: "", else: "AND c.phone_number = $2"}
      ORDER BY s.expires_at DESC NULLS LAST, c.id DESC
      LIMIT #{page_size}
      OFFSET #{(page_number - 1) * page_size}
    """

    query = from c in Customer, where: c.company_id == ^company_id

    # filter by phone number if provided
    query =
      if is_nil(phone_number) do
        query
      else
        from c in query, where: c.phone_number == ^phone_number
      end

    total_count =
      query
      |> Repo.aggregate(:count, :id)

    params = if is_nil(phone_number), do: [company_id], else: [company_id, phone_number]
    # format into map
    result =
      case Repo.query(sql, params) do
        {:ok, %{rows: rows, columns: columns}} ->
          results =
            Enum.map(rows, fn row ->
              Enum.zip(columns, row) |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
            end)
            |> Enum.map(fn customer ->
              %{
                customer
                | status: update_status(customer.last_seen, :customers),
                  time_used: format_used_time(customer.time_used),
                  uploaded_data: convert_data(customer, :upload),
                  downloaded_data: convert_data(customer, :download),
                  total_data: total_data(customer)
              }
            end)

          {:ok, results}

        {:error, error} ->
          {:error, error}
      end

    with {:ok, result} <- result do
      {:ok,
       %{
         customers: result,
         page_number: page_number,
         page_size: page_size,
         total_count: total_count,
         total_pages: ceil(total_count / page_size)
       }}
    end
  end

  def count_customers(company_id) do
    total_customers =
      Customer
      |> where(company_id: ^company_id)
      |> Repo.aggregate(:count, :id)

    current_active =
      Customer
      |> where(company_id: ^company_id, status: "active")
      |> Repo.aggregate(:count, :id)

    data = %{
      total_customers: total_customers,
      current_active: current_active
    }

    {:ok, data}
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

  defp convert_data(customer, :upload) do
    case to_gigabytes(customer.input_octets, customer.input_gigawords) do
      {:mb, value} -> "#{value} MB"
      {:gb, value} -> "#{value} GB"
    end
  end

  defp convert_data(customer, :download) do
    case to_gigabytes(customer.output_octets, customer.output_gigawords) do
      {:mb, value} -> "#{value} MB"
      {:gb, value} -> "#{value} GB"
    end
  end

  def total_data(customer) do
    total_octets = customer.input_octets + customer.output_octets
    total_gigawords = customer.input_gigawords + customer.output_gigawords

    case to_gigabytes(total_octets, total_gigawords) do
      {:mb, value} -> "#{value} MB"
      {:gb, value} -> "#{value} GB"
    end
  end
end
