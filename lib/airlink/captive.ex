defmodule Airlink.Captive do
  alias __MODULE__.Captive, as: CaptiveSchema
  alias __MODULE__.CaptiveServer
  alias Airlink.Customers.Customer

  def get_entry(cookie) do
    CaptiveServer.get_captive_entry(cookie)
  end


  def create_entry(%Customer{uuid: customer_uuid}, %{cookie: cookie} = captive_data) do
    captive_data = captive_data
    |> Map.put_new(:customer_id, customer_uuid)

    CaptiveServer.add_captive_entry(cookie, captive_data)
  end

  def delete_entry(cookie) do
    CaptiveServer.delete_captive_entry(cookie)
  end

  def validate(params) do
    mapped_params = %{
      mac: Map.get(params, "mac") || nil,
      ip: Map.get(params, "ip") || nil,
      company_id: Map.get(params, "company_id") || nil,
      link_login_only: Map.get(params, "link-login-only") || nil,
      link_orig: Map.get(params, "link-orig") || nil,
      hotspot_id: Map.get(params, "server-name") || nil,
      router_id: Map.get(params, "identity") || nil,
      cookie: generate_cookie_key(),
      created_at: DateTime.utc_now()
    }

    %CaptiveSchema{}
    |> CaptiveSchema.changeset(mapped_params)
    |> case do
      %{valid?: true, changes: changes} -> {:ok, changes}
      changeset -> {:error, changeset}
    end
  end

  defp generate_cookie_key() do
    :crypto.strong_rand_bytes(16)
    |> Base.url_encode64(padding: false)
  end
end
