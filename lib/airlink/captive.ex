defmodule Airlink.Captive do
  alias __MODULE__.Captive, as: CaptiveSchema
  alias __MODULE__.CaptiveServer
  alias Airlink.Customers.Customer

  def get_entry(customer_uuid) do
    CaptiveServer.get_captive_entry(customer_uuid)
  end

  def create_entry(%Customer{uuid: customer_uuid} = customer, params) do
    CaptiveServer.add_captive_entry(customer_uuid, {customer, params})
  end

  def delete_entry(customer_uuid) do
    CaptiveServer.delete_captive_entry(customer_uuid)
  end

  def validate(params) do
    %CaptiveSchema{}
    |> CaptiveSchema.changeset(params)
    |> case do
      %{valid?: true, changes: changes} -> {:ok, changes}
      changeset -> {:error, changeset}
    end
  end
end
