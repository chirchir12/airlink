defmodule Airlink.PlansTest do
  use Airlink.DataCase

  alias Airlink.Plans
  alias Airlink.Plans.Plan
  alias Airlink.Hotspots.Hotspot

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
      {:ok, hotspot} =
        %Hotspot{}
        |> Hotspot.changeset(%{name: "Test Hotspot", company_id: Ecto.UUID.generate()})
        |> Repo.insert()

      {:ok, plan} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:hotspot_id, hotspot.id)
        |> Plans.create_plan()

      plan
    end

    test "list_plans/0 returns all plans" do
      plan = plan_fixture()
      {:ok, plans} = Plans.list_plans()
      assert length(plans) == 1
      assert hd(plans).id == plan.id
    end

    test "get_plan_id/1 returns the plan with given id" do
      plan = plan_fixture()
      {:ok, fetched_plan} = Plans.get_plan_id(plan.id)
      assert fetched_plan.id == plan.id
    end

    test "get_plan_uuid/1 returns the plan with given uuid" do
      plan = plan_fixture()
      {:ok, fetched_plan} = Plans.get_plan_uuid(plan.uuid)
      assert fetched_plan.id == plan.id
    end

    test "create_plan/1 with valid data creates a plan" do
      valid_attrs = Map.put(@valid_attrs, :hotspot_id, plan_fixture().hotspot_id)
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

    test "update_plan/2 with valid data updates the plan" do
      plan = plan_fixture()
      assert {:ok, %Plan{} = updated_plan} = Plans.update_plan(plan, @update_attrs)
      assert updated_plan.name == "premium_plan"
      assert updated_plan.description == "An updated premium plan"
      assert updated_plan.duration == 60
      assert updated_plan.bundle_size == 100
    end

    test "update_plan/2 with invalid data returns error changeset" do
      plan = plan_fixture()
      assert {:error, %Ecto.Changeset{}} = Plans.update_plan(plan, @invalid_attrs)
      {:ok, unchanged_plan} = Plans.get_plan_id(plan.id)
      assert plan.name == unchanged_plan.name
      assert plan.description == unchanged_plan.description
    end

    test "delete_plan/1 deletes the plan" do
      plan = plan_fixture()
      assert {:ok, %Plan{}} = Plans.delete_plan(plan)
      assert {:error, :plan_not_found} = Plans.get_plan_id(plan.id)
    end

    test "change_plan/1 returns a plan changeset" do
      plan = plan_fixture()
      assert %Ecto.Changeset{} = Plans.change_plan(plan)
    end

    test "create_plan/1 with invalid time_unit returns error changeset" do
      invalid_attrs = Map.put(@valid_attrs, :time_unit, "invalid_unit")
      assert {:error, %Ecto.Changeset{} = changeset} = Plans.create_plan(invalid_attrs)
      assert "is not supported" in errors_on(changeset).time_unit
    end

    test "create_plan/1 with invalid bundle_unit returns error changeset" do
      invalid_attrs = Map.put(@valid_attrs, :bundle_unit, "invalid_unit")
      assert {:error, %Ecto.Changeset{} = changeset} = Plans.create_plan(invalid_attrs)
      assert "is not supported" in errors_on(changeset).bundle_unit
    end

    test "create_plan/1 with name containing spaces returns error changeset" do
      invalid_attrs = Map.put(@valid_attrs, :name, "plan with spaces")
      assert {:error, %Ecto.Changeset{} = changeset} = Plans.create_plan(invalid_attrs)
      assert "must not contain spaces" in errors_on(changeset).name
    end
  end
end
