defmodule Airlink.Payments.PaymentConsumer do
  @behaviour GenRMQ.Consumer
  alias GenRMQ.Message
  require Logger
  alias Airlink.Payments
  import Airlink.Helpers

  def start_link() do
    GenRMQ.Consumer.start_link(__MODULE__, name: __MODULE__)
  end

  def ack(%Message{attributes: %{delivery_tag: tag}} = message) do
    Logger.debug("Message successfully processed. Tag: #{tag}")
    GenRMQ.Consumer.ack(message)
  end

  def reject(%Message{attributes: %{delivery_tag: tag}} = message, requeue \\ true) do
    Logger.info("Rejecting message, tag: #{tag}, requeue: #{requeue}")
    GenRMQ.Consumer.reject(message, requeue)
  end

  @impl GenRMQ.Consumer
  def init() do
    options = get_options()
    options
  end

  @impl GenRMQ.Consumer
  def handle_message(%Message{payload: payload} = message) do
    Logger.info("Received message: #{inspect(message)}")
    payload = Jason.decode!(payload) |> atomize_map_keys()
    :ok = Payments.update_payments(payload)
    ack(message)
  end

  @impl GenRMQ.Consumer
  def handle_error(%Message{attributes: attributes, payload: payload} = message, reason) do
    Logger.error(
      "Rejecting message due to consumer task error: #{inspect(reason: reason, msg_attributes: attributes, msg_payload: payload)}"
    )

    GenRMQ.Consumer.reject(message, false)
  end

  @impl GenRMQ.Consumer
  def consumer_tag() do
    {:ok, hostname} = :inet.gethostname()
    "#{hostname}-payment-consumer"
  end

  defp get_options() do
    :airlink
    |> Application.get_env(__MODULE__)
  end
end
