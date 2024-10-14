defmodule Airlink.RmqPulbisher do
  @behaviour GenRMQ.Publisher
  require Logger

  def start_link() do
    GenRMQ.Publisher.start_link(__MODULE__, name: __MODULE__)
  end

  @impl true
  def init() do
    config = get_options()

    [
      exchange: config[:exchange],
      uri: config[:url],
      durable: true
    ]
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    }
  end

  def publish(data, queue) do
    data
    |> encode_message()
    |> publish_data(queue)
  end

  defp publish_data(encoded_data, queue)
       when is_binary(encoded_data) and byte_size(encoded_data) > 0 do
    case GenRMQ.Publisher.publish(__MODULE__, encoded_data, queue) do
      :ok ->
        {:ok, :ok}

      {:ok, :confirmed} ->
        {:ok, :ok}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp publish_data(_message, _queue) do
    {:error, "Invalid data"}
  end

  defp encode_message(data) do
    Jason.encode!(data)
  end

  defp get_options() do
    :diralink
    |> Application.get_env(__MODULE__)
  end
end
