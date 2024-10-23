defmodule Airlink.HotspotsTest do
  use Airlink.DataCase

  alias Airlink.Hotspots
  alias Airlink.Hotspots.Hotspot

  @valid_attrs %{
    name: "Test Hotspot",
    description: "Test Description",
    bridge_name: "Test Bridge",
    landmark: "Test Landmark",
    company_id: Ecto.UUID.generate(),
    router_id: Ecto.UUID.generate(),
    latitude: 40.7128,
    longitude: -74.0060
  }
  @update_attrs %{
    name: "Updated Hotspot",
    description: "Updated Description",
    bridge_name: "Updated Bridge",
    landmark: "Updated Landmark",
    latitude: 41.8781,
    longitude: -87.6298
  }
  @invalid_attrs %{
    name: nil,
    description: nil,
    bridge_name: nil,
    landmark: nil,
    company_id: nil,
    router_id: nil
  }

  def hotspot_fixture(attrs \\ %{}) do
    {:ok, hotspot} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Hotspots.create_hotspot()

    hotspot
  end

  describe "list_hotspots/1" do
    test "returns all hotspots" do
      hotspot = hotspot_fixture()
      {:ok, hotspots} = Hotspots.list_hotspots(hotspot.company_id)
      assert hotspots == [hotspot]
    end
  end

  describe "get_hotspot_by_id/1" do
    test "returns the hotspot with given id" do
      hotspot = hotspot_fixture()
      {:ok, fetched_hotspot} = Hotspots.get_hotspot_by_id(hotspot.id)
      assert fetched_hotspot == hotspot
    end

    test "returns error when hotspot not found" do
      assert {:error, :hotspot_not_found} = Hotspots.get_hotspot_by_id(-1)
    end
  end

  describe "get_hotspot_by_uuid/1" do
    test "returns the hotspot with given uuid" do
      hotspot = hotspot_fixture()
      {:ok, fetched_hotspot} = Hotspots.get_hotspot_by_uuid(hotspot.uuid)
      assert fetched_hotspot == hotspot
    end

    test "returns error when hotspot not found" do
      assert {:error, :hotspot_not_found} = Hotspots.get_hotspot_by_uuid(Ecto.UUID.generate())
    end
  end

  describe "create_hotspot/1" do
    test "with valid data creates a hotspot" do
      assert {:ok, %Hotspot{} = hotspot} = Hotspots.create_hotspot(@valid_attrs)
      assert hotspot.name == "Test Hotspot"
      assert hotspot.description == "Test Description"
      assert hotspot.bridge_name == "Test Bridge"
      assert hotspot.landmark == "Test Landmark"
      assert hotspot.company_id == @valid_attrs.company_id
      assert hotspot.router_id == @valid_attrs.router_id
      assert hotspot.latitude == 40.7128
      assert hotspot.longitude == -74.0060
      assert is_binary(hotspot.uuid)
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hotspots.create_hotspot(@invalid_attrs)
    end
  end

  describe "update_hotspot/2" do
    test "with valid data updates the hotspot" do
      hotspot = hotspot_fixture()
      assert {:ok, %Hotspot{} = updated_hotspot} = Hotspots.update_hotspot(hotspot, @update_attrs)
      assert updated_hotspot.name == "Updated Hotspot"
      assert updated_hotspot.description == "Updated Description"
      assert updated_hotspot.bridge_name == "Updated Bridge"
      assert updated_hotspot.landmark == "Updated Landmark"
      assert updated_hotspot.latitude == 41.8781
      assert updated_hotspot.longitude == -87.6298
    end

    test "with invalid data returns error changeset" do
      hotspot = hotspot_fixture()
      assert {:error, %Ecto.Changeset{}} = Hotspots.update_hotspot(hotspot, @invalid_attrs)
      {:ok, unchanged_hotspot} = Hotspots.get_hotspot_by_id(hotspot.id)
      assert hotspot == unchanged_hotspot
    end
  end

  describe "delete_hotspot/1" do
    test "deletes the hotspot" do
      hotspot = hotspot_fixture()
      assert {:ok, %Hotspot{}} = Hotspots.delete_hotspot(hotspot)
      assert {:error, :hotspot_not_found} = Hotspots.get_hotspot_by_id(hotspot.id)
    end
  end

  describe "change_hotspot/2" do
    test "returns a hotspot changeset" do
      hotspot = hotspot_fixture()
      assert %Ecto.Changeset{} = Hotspots.change_hotspot(hotspot)
    end
  end
end
