defmodule Airlink.Captive.CaptiveRateLimiter do
  use GenServer
  @table_name :rate_limit_cache
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def increment_count(customer_uuid, new_timestamp, count) do
    :ets.insert(@table_name, {customer_uuid, new_timestamp, count})
  end

  def lookup(customer_uuid) do
    case :ets.lookup(@table_name, customer_uuid) do
      [{^customer_uuid, timestamp, count}] -> {:ok, {customer_uuid, timestamp, count}}
      [] -> {:error, :rate_limit_not_set}
    end
  end

  def reset(customer_uuid, after_ms) do
    Process.whereis(__MODULE__)
    |> Process.send_after({:reset, customer_uuid}, after_ms)
    :ok
  end

  # Server Callbacks
  @impl true
  def init(_args) do
    table =
      :ets.new(@table_name, [
        :set,
        :public,
        :named_table,
        write_concurrency: true,
        read_concurrency: true
      ])
      schedule_sweep()
    {:ok, table}
  end

  @impl true
  def handle_info({:reset, customer_uuid}, state) do
    :ets.delete(@table_name, customer_uuid)
    {:noreply, state}
  end

  @impl true
  def handle_info(:sweep, table) do
    sweep(table)
    {:noreply, table}
  end


  # private
  defp sweep(table) do
    now = System.monotonic_time(:second)
    opts = :airlink |> Application.get_env(:captive)
    sweep_after = opts[:rate_limit][:sweep_after_in_sec]

    :ets.foldl(
      fn
        {mac_add, last_timestamp, _count} = entry, acc ->
          if now - last_timestamp >= sweep_after do
            :ok = Logger.debug("Cleared Rate Limit Data: #{inspect(entry)}")
            :ets.delete(table, mac_add)
            [entry | acc]
          else
            acc
          end
      end,
      [],
      table
    )

    schedule_sweep()
    table
  end

  defp schedule_sweep() do
    opts = :airlink |> Application.get_env(:captive)
    sweep_after = opts[:rate_limit][:sweep_after_in_sec]
    Process.send_after(self(), :sweep, sweep_after * 1000)
  end
end
