defmodule Airlink.HttpClient do
  use HTTPoison.Base

  @doc false
  def process_request_body(body)

  def process_request_body(body) when is_map(body) do
    Jason.encode!(body)
  end

  def process_request_body(body), do: body

  @doc false
  def process_request_headers(headers) do
    [{"Content-Type", "application/json"}, {"x-app_name", "airlink"} | headers]
  end

  @doc false
  def process_response_body(body)

  def process_response_body(body) when byte_size(body) > 0 do
    case Jason.decode(body) do
      {:ok, decoded} ->
        decoded

      {:error, _reason} ->
        %{"error" => "jason_decode_error", "original_body" => body}
    end
  end

  def process_response_body(_body) do
    {:error, :unexpected_error}
  end
end
