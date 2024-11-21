defmodule Airlink.AccountingHandler do
  use Broadway
  alias Broadway.Message
  require Logger
  import Airlink.Helpers

  def start_link(option) do
    Broadway.start_link(__MODULE__, [name: __MODULE__] ++ option)
  end

  def handle_message(_, %Message{data: params} = message, _ctx) do
    params = Jason.decode!(params) |> atomize_map_keys()

    with :ok <- process_message(params) do
      message
    else
      error ->
        Logger.error("Got error: #{inspect(error)}: Params: #{inspect(params)}")
        message
    end
  end

  def process_message(params) do
    Logger.info("Processing message: #{inspect(params)}")
    :ok
  end
end
