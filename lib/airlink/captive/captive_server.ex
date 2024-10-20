defmodule Airlink.Captive.CaptiveServer do
  use GenServer
  require Logger

  @table_name :captive_cache
  # 1 min
  @schedule_clean_up_after 60_000
  # 30 mins
  @expiration_period 30 * 60

  # Client API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_captive_entry(cookie, captive_data) do
    GenServer.call(__MODULE__, {:add_captive_entry, cookie, captive_data})
  end

  def delete_captive_entry(cookie) do
    GenServer.call(__MODULE__, {:delete_captive_entry, cookie})
  end

  def get_captive_entry(cookie) do
    GenServer.call(__MODULE__, {:get_captive_entry, cookie})
  end

  # Server Callbacks

  @impl true
  def init(_args) do
    table = :ets.new(@table_name, [:set, :protected, :named_table])
    :ok = schedule_evacution()
    {:ok, table}
  end

  @impl true
  def handle_call(
        {:add_captive_entry, cookie, captive_data},
        _from,
        table
      ) do
    result = :ets.insert(table, {cookie, captive_data})

    {:reply, result, table}
  end

  @impl true
  def handle_call({:delete_captive_entry, cookie}, _from, table) do
    result =
      case :ets.lookup(table, cookie) do
        [{^cookie, _captive_data}] ->
          result = :ets.delete(table, cookie)
          {:ok, result}

        [] ->
          {:error, :captive_data_not_found}
      end

    {:reply, result, table}
  end

  @impl true
  def handle_call({:get_captive_entry, cookie}, _from, table) do
    result =
      case :ets.lookup(table, cookie) do
        [{^cookie, data}] -> {:ok, data}
        [] -> {:error, :captive_data_not_found}
      end

    {:reply, result, table}
  end

  @impl true
  def handle_info(:clear_expired, table) do
    result = clear_expired(table)
    {:noreply, result}
  end

  defp schedule_evacution() do
    _ = Process.send_after(self(), :clear_expired, @schedule_clean_up_after)
    :ok
  end

  defp clear_expired(table) do
    now = DateTime.utc_now()
    cutoff = DateTime.add(now, - @expiration_period, :second)

    :ets.foldl(
      fn
        {cookie,  %{created_at: created_at}} = entry, acc
        when is_struct(created_at, DateTime) ->
          if DateTime.compare(created_at, cutoff) == :lt do
            :ets.delete(table, cookie)
            [entry | acc]
          else
            acc
          end

        entry, acc ->
          Logger.warning("[#{inspect(__MODULE__)}] Unexpected entry format: #{inspect(entry)}")
          acc
      end,
      [],
      table
    )

    schedule_evacution()
    table
  end
end
