defmodule Airlink do
  @moduledoc """
  Airlink keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Airlink.RmqPublisher
  alias Airlink.Plans
  alias Airlink.Customers
  alias Airlink.Subscriptions.Subscription

  def publish(%Subscription{} = sub) do
    {:ok, plan} = Plans.get_plan_id(sub.plan_id)
    {:ok, cust} = Customers.get_customer_by_id(sub.customer_id)

    %{
      username: cust.username,
      password: cust.password_hash,
      customer: cust.uuid,
      service: "hotspot",
      duration_mins: Plans.calculate_duration_mins(plan),
      plan: plan.uuid,
      action: "session_activate",
      sender: :airlink
    }
    |> publish(:subscription)
  end

  def publish(data, :subscription) do
    queue = System.get_env("RMQ_SUBSCRIPTION_ROUTING_KEY") || "hotspot_subscription_changes_rk"
    {:ok, :ok} = RmqPublisher.publish(data, queue)
    :ok
  end
end
