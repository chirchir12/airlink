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
    path = get_path("hotspot.csv")
    {:ok, count} = read_csv(path, &transform_hotspots/1)
    :ok = Logger.info("[HOTSPOTS] inserted #{count} Rows!!", table: "hotspots")
    :ok
  end

  def plans do
    path = get_path("plan.csv")
    {:ok, count} = read_csv(path, &transform_plans/1)
    :ok = Logger.info("[PLANS] inserted #{count} Rows!!", table: "plans")
    :ok
  end

  def customers() do
    path = get_path("customer.csv")
    {:ok, count} = read_csv(path, &transform_customer/1)
    :ok = Logger.info("[CUSTOMERS] inserted #{count} Rows!!", table: "customers")
    :ok
  end

  def subscriptions do
    path = get_path("subscription.csv")
    {:ok, count} = read_csv(path, &transform_subscription/1)
    Logger.info("[SUBSCRIPTIONS] inserted #{count} Rows!!", table: "subsriptions")
    :ok
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
    duration_mins =
      Airlink.Plans.calculate_duration_mins(
        row["duration"] |> String.to_integer(),
        row["time_unit"]
      )

    {:ok, sub} =
      %{
        customer_id: row["customer_id"],
        plan_id: row["plan_id"],
        status: row["status"],
        expires_at: row["expires_at"],
        company_id: row["company_id"],
        activated_at: calculate_activated_at(row["expires_at"], duration_mins),
        meta: nil
      }
      |> Airlink.Subscriptions.create_subscription()

    :ok = publish(row, sub)
    {:ok, sub}
  end

  defp publish(row, sub) do
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
      expire_on: row["expires_at"],
      subscription: sub.uuid
    }

    queue = System.get_env("RMQ_SUBSCRIPTION_ROUTING_KEY") || "hotspot_subscription_changes_rk"
    :ok = Airlink.publish(data, queue)
    :ok = Logger.info("Published #{row["username"]} Session to #{queue}")
    :ok
  end

  defp read_csv(path, transformer) when is_function(transformer) do
    count =
      path
      |> File.stream!([{:read_ahead, 100_000}])
      |> CSV.decode(headers: true, field_transform: &String.trim/1)
      |> Enum.reduce(0, fn row, acc ->
        case transformer.(row) do
          {:ok, _} ->
            acc + 1

          error ->
            Logger.warning("Failed to insert #{inspect(error)}")
            acc
        end
      end)

    {:ok, count}
  end

  defp get_path(filename) do
    Path.join(["/tmp/airlink", filename])
  end

  def calculate_activated_at(expires_at, duration_mins) do
    case DateTime.from_iso8601(expires_at) do
      {:ok, datetime, _offset} ->
        datetime
        |> DateTime.add(-duration_mins * 60, :second)

      {:error, reason} ->
        Logger.error("Failed to parse datetime: #{reason}")
        nil
    end
  end
end
