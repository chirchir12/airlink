defmodule Airlink.PlansTest do
  use Airlink.DataCase

  alias Airlink.Plans
  alias Airlink.Plans.Plan
  alias Airlink.Hotspots

  setup do
    hotspot_attrs = %{
      name: "Test Hotspot",
      description: "Test Description",
      bridge_name: "Test Bridge",
      landmark: "Test Landmark",
      company_id: Ecto.UUID.generate(),
      router_id: Ecto.UUID.generate()
    }

    {:ok, hotspot} = Hotspots.create_hotspot(hotspot_attrs)
    %{hotspot: hotspot}
  end

  describe "plans" do
    @valid_attrs %{
      name: "basic_plan",
      description: "A basic plan for testing",
      duration: 30,
      time_unit: "day",
      upload_speed: 10,
      download_speed: 20,
      speed_unit: "MBps",
      bundle_size: 50,
      bundle_unit: "GB",
      price: Decimal.new("29.99"),
      currency: "KES",
      company_id: Ecto.UUID.generate(),
      hotspot_id: nil
    }
    @update_attrs %{
      name: "premium_plan",
      description: "An updated premium plan",
      duration: 60,
      bundle_size: 100
    }
    @invalid_attrs %{name: nil, description: nil, duration: nil, time_unit: nil}

    def plan_fixture(attrs \\ %{}) do
      {:ok, plan} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Plans.create_plan()

      plan
    end

    test "list_plans/2 returns all plans", %{hotspot: hotspot} do
      plan = plan_fixture(%{hotspot_id: hotspot.id})
      {:ok, plans} = Plans.list_plans(plan.company_id,hotspot.id)
      assert length(plans) == 1
      assert hd(plans).id == plan.id
    end

    test "list_plans/1 returns all plans", %{hotspot: hotspot} do
      plan = plan_fixture(%{hotspot_id: hotspot.id})
      {:ok, plans} = Plans.list_plans(plan.company_id)
      assert length(plans) == 1
      assert hd(plans).id == plan.id
    end

    test "get_plan_id/1 returns the plan with given id", %{hotspot: hotspot} do
      plan = plan_fixture(%{hotspot_id: hotspot.id})
      {:ok, fetched_plan} = Plans.get_plan_id(plan.id)
      assert fetched_plan.id == plan.id
    end

    test "get_plan_uuid/1 returns the plan with given uuid", %{hotspot: hotspot} do
      plan = plan_fixture(%{hotspot_id: hotspot.id})
      {:ok, fetched_plan} = Plans.get_plan_uuid(plan.uuid)
      assert fetched_plan.id == plan.id
    end

    test "create_plan/1 with valid data creates a plan", %{hotspot: hotspot} do
      valid_attrs = Map.put(@valid_attrs, :hotspot_id, hotspot.id)
      assert {:ok, %Plan{} = plan} = Plans.create_plan(valid_attrs)
      assert plan.name == "basic_plan"
      assert plan.description == "A basic plan for testing"
      assert plan.duration == 30
      assert plan.time_unit == "day"
      assert plan.bundle_size == 50
      assert plan.bundle_unit == "GB"
      assert Decimal.equal?(plan.price, Decimal.new("29.99"))
    end

    test "create_plan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Plans.create_plan(@invalid_attrs)
    end

    test "update_plan/2 with valid data updates the plan", %{hotspot: hotspot} do
      plan = plan_fixture(%{hotspot_id: hotspot.id})
      assert {:ok, %Plan{} = updated_plan} = Plans.update_plan(plan, @update_attrs)
      assert updated_plan.name == "premium_plan"
      assert updated_plan.description == "An updated premium plan"
      assert updated_plan.duration == 60
      assert updated_plan.bundle_size == 100
    end

    test "update_plan/2 with invalid data returns error changeset", %{hotspot: hotspot} do
      plan = plan_fixture(%{hotspot_id: hotspot.id})
      assert {:error, %Ecto.Changeset{}} = Plans.update_plan(plan, @invalid_attrs)
      {:ok, unchanged_plan} = Plans.get_plan_id(plan.id)
      assert plan.name == unchanged_plan.name
      assert plan.description == unchanged_plan.description
    end

    test "delete_plan/1 deletes the plan", %{hotspot: hotspot} do
      plan = plan_fixture(%{hotspot_id: hotspot.id})
      assert {:ok, %Plan{}} = Plans.delete_plan(plan)
      assert {:error, :plan_not_found} = Plans.get_plan_id(plan.id)
    end

    test "change_plan/1 returns a plan changeset", %{hotspot: hotspot} do
      plan = plan_fixture(%{hotspot_id: hotspot.id})
      assert %Ecto.Changeset{} = Plans.change_plan(plan)
    end

    test "create_plan/1 with invalid time_unit returns error changeset", %{hotspot: hotspot} do
      invalid_attrs = @valid_attrs
                    |> Map.put(:hotspot_id, hotspot.id)
                    |> Map.put(:time_unit, "invalid_unit")

      assert {:error, %Ecto.Changeset{} = changeset} = Plans.create_plan(invalid_attrs)
      assert "is not supported" in errors_on(changeset).time_unit
    end


    test "create_plan/1 with name containing spaces returns error changeset",  %{hotspot: hotspot} do
      invalid_attrs = @valid_attrs
                    |> Map.put(:hotspot_id, hotspot.id)
                    |>Map.put(:name, "plan with spaces")
      assert {:error, %Ecto.Changeset{} = changeset} = Plans.create_plan(invalid_attrs)
      assert "must not contain spaces" in errors_on(changeset).name
    end
  end
end
