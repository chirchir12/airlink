defmodule AirlinkWeb.PaymentJSON do
  alias Airlink.Subscriptions.Subscription

  def show(%{subscription: subscription}) do
    %{data: data(subscription)}
  end

  defp data(%Subscription{} = sub) do
    %{
      status: sub.status,
      ref_id: sub.uuid
    }
  end
end
