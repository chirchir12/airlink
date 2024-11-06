defmodule Airlink.Migrations.Airlink do
  @moduledoc """
  Module to help migrate existing database
  """
  require Logger
  import Airlink.Helpers

  def run do
    hotspots()
    plans()
    customers()
  end

  def hotspots do
    file_name = "hotspot.csv"
    path = Path.join(["/tmp/airlink", file_name])

    count =
      path
      |> File.stream!([{:read_ahead, 100_000}])
      |> CSV.decode(headers: true, field_transform: &String.trim/1)
      |> Enum.reduce(0, fn row, acc ->
        case transform_hotspots(row) do
          {:ok, _} ->
            acc + 1

          error ->
            Logger.warning("Failed to insert #{inspect(error)}")
            acc
        end
      end)

    Logger.info("[HOTSPOTS] inserted #{count} Rows!!", table: "hotspots")
    {:ok, count}
  end

  def plans do
    file_name = "plan.csv"
    path = Path.join(["/tmp/airlink", file_name])

    count =
      path
      |> File.stream!([{:read_ahead, 100_000}])
      |> CSV.decode(headers: true, field_transform: &String.trim/1)
      |> Enum.reduce(0, fn row, acc ->
        case transform_plans(row) do
          {:ok, _} ->
            acc + 1

          error ->
            Logger.warning("Failed to insert #{inspect(error)}")
            acc
        end
      end)

    Logger.info("[PLANS] inserted #{count} Rows!!", table: "plans")
    {:ok, count}
  end

  def customers() do
    file_name = "customer.csv"
    path = Path.join(["/tmp/airlink", file_name])

    count =
      path
      |> File.stream!([{:read_ahead, 100_000}])
      |> CSV.decode(headers: true, field_transform: &String.trim/1)
      |> Enum.reduce(0, fn row, acc ->
        case transform_customer(row) do
          {:ok, _} ->
            acc + 1

          error ->
            Logger.warning("Failed to insert #{inspect(error)}")
            acc
        end
      end)

    Logger.info("[CUSTOMERS] inserted #{count} Rows!!", table: "hotspots")
    {:ok, count}
  end

  def subscriptions do
    file_name = "subscription.csv"
    path = Path.join(["/tmp/airlink", file_name])

    count =
      path
      |> File.stream!([{:read_ahead, 100_000}])
      |> CSV.decode(headers: true, field_transform: &String.trim/1)
      |> Enum.reduce(0, fn row, acc ->
        case transform_subscription(row) do
          {:ok, _} ->
            :ok = publish(row)
            acc + 1

          error ->
            Logger.warning("Failed to insert #{inspect(error)}")
            acc
        end
      end)

    Logger.info("[SUBSCRIPTIONS] inserted #{count} Rows!!", table: "subsriptions")
    {:ok, count}
  end

  defp transform_hotspots({:ok, row}) do
    %{
      id: String.to_integer(row["id"]),
      uuid: row["uuid"],
      name: row["name"],
      description: row["description"],
      bridge_name: row["bridge_name"],
      landmark: row["landmark"],
      company_id: row["company_id"],
      latitude: nil,
      longitude: nil,
      router_id: row["router_id"],
      inserted_at: row["inserted_at"],
      updated_at: row["updated_at"]
    }
    |> Airlink.Hotspots.create_hotspot()
  end

  def transform_plans({:ok, row}) do
    %{
      id: String.to_integer(row["id"]),
      uuid: row["uuid"],
      name: row["name"],
      description: row["name"],
      duration: String.to_integer(row["duration"]),
      time_unit: row["time_unit"],
      upload_speed: String.to_integer(row["upload_speed"]),
      download_speed: String.to_integer(row["download_speed"]),
      speed_unit: row["speed_unit"],
      bundle_size: 15,
      bundle_unit: "GB",
      price: row["price"],
      currency: "KES",
      company_id: row["company_id"],
      hotspot_id: String.to_integer(row["hotspot_id"]),
      inserted_at: row["inserted_at"],
      updated_at: row["updated_at"]
    }
    |> Airlink.Plans.create_plan()
  end

  defp transform_customer({:ok, row}) do
    %{
      id: String.to_integer(row["id"]),
      uuid: row["uuid"],
      username: row["username"] |> normalize_mac(),
      password_hash: row["password_hash"],
      company_id: row["company_id"],
      status: row["status"],
      first_name: nil,
      last_name: nil,
      email: nil,
      phone_number: row["phone_number"],
      inserted_at: row["inserted_at"],
      updated_at: row["updated_at"]
    }
    |> Airlink.Customers.create_customer()
  end

  defp transform_subscription({:ok, row}) do
    %{
      customer_id: row["customer_id"],
      plan_id: row["plan_id"],
      status: row["status"],
      expires_at: row["expires_at"],
      company_id: row["company_id"],
      meta: nil
    }
    |> IO.inspect()
    |> Airlink.Subscriptions.create_subscription()
  end

  defp publish({:ok, row}) do
    data = %{
      username: row["username"] |> normalize_mac(),
      password: row["password"],
      customer: row["customer_uuid"],
      service: "hotspot",
      duration_mins:
        Airlink.Plans.calculate_duration_mins(
          row["duration"] |> String.to_integer(),
          row["time_unit"]
        ),
      plan: row["plan_uuid"],
      action: "session_activate",
      sender: :airlink,
      expire_on: row["expires_at"]
    }

    queue = System.get_env("RMQ_SUBSCRIPTION_ROUTING_KEY") || "hotspot_subscription_changes_rk"
    {:ok, :ok} = Airlink.RmqPublisher.publish(data, queue)
    :ok = Logger.info("Published #{row["username"]} Session to #{queue}")
    :ok
  end
end
