defmodule AirlinkWeb.PaymentJSON do
  alias Airlink.Subscriptions.Subscription

  def show(%{payment: {customer, subscription}}) do
    %{data: data(customer, subscription)}
  end

  defp data(customer, %Subscription{} = sub) do
    is_activated = case customer.status do
      "active" -> true
      "inactive" -> false

    end
    %{
      status: sub.status,
      ref_id: sub.uuid,
      is_activated: is_activated
    }
  end
end
