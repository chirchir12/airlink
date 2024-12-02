defmodule AirlinkWeb.SubscriptionController do
  use AirlinkWeb, :controller
  alias Airlink.Subscriptions
  alias Airlink.Plans
  plug AirlinkWeb.CheckRolesPlug, ["%", "admin", "system"]
  action_fallback AirlinkWeb.FallbackController

  def reactivate(conn, %{"params" => params, "current_sub_id" => curr_sub_uuid}) do
    params = params |> Map.put_new("curr_sub_uuid", curr_sub_uuid)

    with {:ok, params} <- Subscriptions.validate_reactivation(params),
         {:ok, current_sub} <- Subscriptions.get_subscription_by_uuid(curr_sub_uuid),
         {:ok, plan} <- Plans.get_plan_id(current_sub.plan_id),
         {:ok, sub} <- reactivate_sub(params, plan, current_sub),
         :ok <- publish_reactivation(params, sub) do
      conn
      |> put_status(:ok)
      |> render(:show, subscription: sub)
    end
  end

  defp reactivate_sub(%{action: action} = params, plan, current_sub) do
    case action do
      "full" -> reactivate_full(plan, current_sub)
      "remaining" -> reactivate_remaining(params, plan, current_sub)
    end
  end

  defp reactivate_full(plan, current_sub) do
    duration_mins = Plans.calculate_duration_mins(plan)
    current_time = DateTime.utc_now()

    %{
      status: "completed",
      customer_id: current_sub.customer_id,
      plan_id: current_sub.plan_id,
      expires_at: DateTime.add(current_time, duration_mins, :minute),
      activated_at: DateTime.utc_now(),
      company_id: current_sub.company_id,
      meta: %{
        action: "reactivate in full",
        renewed_duration_mins: duration_mins
      }
    }
    |> Subscriptions.create_subscription()
  end

  defp reactivate_remaining(params, plan, current_sub) do
    duration_mins = Plans.calculate_duration_mins(plan)
    remaining_time = duration_mins * 60 - params.time_used_in_sec
    current_time = DateTime.utc_now()

    %{
      status: "completed",
      customer_id: current_sub.customer_id,
      plan_id: current_sub.plan_id,
      expires_at: DateTime.add(current_time, remaining_time, :second),
      activated_at: DateTime.utc_now(),
      company_id: current_sub.company_id,
      meta: %{
        action: "reactivate remaining",
        renewed_duration_mins: div(remaining_time, 60)
      }
    }
    |> Subscriptions.create_subscription()
  end

  defp publish_reactivation(%{action: action}, sub) do
    case action do
      "full" -> publish(sub, :full)
      "remaining" -> publish(sub, :remaining)
    end
  end

  defp publish(sub, :full) do
    Airlink.publish(sub)
  end

  defp publish(sub, :remaining) do
    remaining_time = sub.meta["renewed_duration_mins"]
    Airlink.publish(sub, remaining_time)
  end
end
