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
  alias Airlink.Plans.Plan
  import Airlink.Helpers

  def publish(%Subscription{} = sub) do
    {:ok, plan} = Plans.get_plan_id(sub.plan_id)
    {:ok, cust} = Customers.get_customer_by_id(sub.customer_id)

    %{
      username: cust.username |> normalize_mac(),
      password: cust.password_hash,
      customer: cust.uuid,
      service: "hotspot",
      duration_mins: Plans.calculate_duration_mins(plan),
      plan: plan.uuid,
      action: "session_activate",
      sender: :airlink
    }
    |> publish(subs_queue())
  end

  def publish(%Plan{} = plan, action) do
    %{
      action: action,
      plan: plan.uuid,
      upload: plan.upload_speed,
      download: plan.download_speed,
      service: "hotspot",
      duration: Plans.calculate_duration_mins(plan) * 60
    }
    |> publish(plans_queue())
  end

  def publish(data, queue) do
    {:ok, :ok} = RmqPublisher.publish(data, queue)
    :ok
  end

  defp subs_queue do
    System.get_env("RMQ_SUBSCRIPTION_ROUTING_KEY") || "hotspot_subscription_changes_rk"
  end

  defp plans_queue do
    System.get_env("RMQ_PLAN_ROUTING_KEY") || "rmq_plan_changes_rk"
  end
end
