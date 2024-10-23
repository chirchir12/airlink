defmodule Airlink.HelpersTest do
  use ExUnit.Case, async: true
  alias Airlink.Helpers


  # Define a simple struct for testing
  defmodule TestStruct do
    defstruct [:id, :uuid]
  end

  def callback(_params), do: :ok


  describe "kw_to_map/1" do
    test "converts keyword list to map" do
      input = [a: 1, b: 2, c: [d: 3, e: 4]]
      expected = %{a: 1, b: 2, c: %{d: 3, e: 4}}
      assert Helpers.kw_to_map(input) == expected
    end

    test "returns non-keyword list as is" do
      input = [1, 2, 3]
      assert Helpers.kw_to_map(input) == input
    end

    test "returns non-list input as is" do
      input = "not a list"
      assert Helpers.kw_to_map(input) == input
    end
  end

  describe "get_config/1" do
    test "retrieves and converts config to map" do
      Application.put_env(:airlink, :test_config, a: 1, b: [c: 2])
      expected = %{a: 1, b: %{c: 2}}
      assert Helpers.get_config(:test_config) == expected
    end
  end

  describe "basic_auth/1" do
    test "generates basic auth header" do
      config = %{username: "user", password: "pass"}
      [{"Authorization", value}] = Helpers.basic_auth(config)
      assert value == "Basic #{Base.encode64("user:pass")}"
    end
  end

  describe "bearer_auth/1" do
    test "generates bearer auth header" do
      token = "my_token"
      [{"Authorization", value}] = Helpers.bearer_auth(token)
      assert value == "Bearer my_token"
    end
  end

  describe "atomize_map_keys/1" do
    test "converts string keys to atoms in map" do
      input = %{"a" => 1, "b" => %{"c" => 2}}
      expected = %{a: 1, b: %{c: 2}}
      assert Helpers.atomize_map_keys(input) == expected
    end

    test "handles lists of maps" do
      input = [%{"a" => 1}, %{"b" => 2}]
      expected = [%{a: 1}, %{b: 2}]
      assert Helpers.atomize_map_keys(input) == expected
    end
  end

  describe "process_message/2" do
    test "processes list of messages" do
      messages = [%{"type" => "test1"}, %{"type" => "test2"}]

      :ok= Helpers.process_message(messages, &callback/1)

    end

    test "ignores messages from airlink" do
      message = %{"sender" => "airlink", "content" => "test"}
      :ok = Helpers.process_message(message, &callback/1)
    end

    test "processes non-airlink messages" do
      message = %{"sender" => "user", "content" => "test"}
      :ok = Helpers.process_message(message, &callback/1)

    end
  end
end
