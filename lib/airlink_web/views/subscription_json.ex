defmodule AirlinkWeb.SubscriptionJSON do
  alias Airlink.Subscriptions.Subscription

  def show(%{"subscription" => subscription}) do
    %{data: data(subscription)}
  end

  def data(%Subscription{} = subscription) do
    %{
      id: subscription.id,
      uuid: subscription.uuid,
      expires_at: subscription.expires_at,
      activated_at: subscription.activated_at,
      status: subscription.status,
      meta: subscription.meta,
      company_id: subscription.company_id,
      customer_id: subscription.customer_id,
      plan_id: subscription.plan_id
    }
  end
end
