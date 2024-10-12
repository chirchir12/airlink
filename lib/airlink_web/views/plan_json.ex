defmodule AirlinkWeb.PlanJSON do
  alias Airlink.Plans.Plan

  @doc """
  Renders a list of plans.
  """
  def index(%{plans: plans}) do
    %{data: for(plan <- plans, do: data(plan))}
  end

  @doc """
  Renders a single plan.
  """
  def show(%{plan: plan}) do
    %{data: data(plan)}
  end

  defp data(%Plan{} = plan) do
    %{
      id: plan.id,
      uuid: plan.uuid,
      name: plan.name,
      duration: plan.duration,
      time_unit: plan.time_unit,
      upload_speed: plan.upload_speed,
      download_speed: plan.download_speed,
      speed_unit: plan.speed_unit,
      bundle_size: plan.bundle_size,
      bundle_unit: plan.bundle_unit,
      price: plan.price,
      currency: plan.currency,
      company_id: plan.company_id,
      hotspot_id: plan.hotspot_id
    }
  end
end
