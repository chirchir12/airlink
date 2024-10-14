defmodule AirlinkWeb.PaymentJSON do
alias Airlink.Subscriptions.Subscription
  def show(%{subscription: subscription}) do
    %{data: data(subscription)}
  end

  defp data(%Subscription{} = sub) do
    %{
      status: sub.status,
      customer_id: sub.customer_id
    }
  end

end
