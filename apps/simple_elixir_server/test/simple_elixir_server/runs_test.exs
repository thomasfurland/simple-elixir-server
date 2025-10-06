defmodule SimpleElixirServer.RunsTest do
  use SimpleElixirServer.DataCase

  alias SimpleElixirServer.Runs.Run

  describe "changeset/2" do
    test "valid changeset with required fields" do
      attrs = %{user_id: 1}
      changeset = Run.changeset(%Run{}, attrs)
      assert changeset.valid?
    end

    test "valid changeset with all fields" do
      attrs = %{
        user_id: 1,
        title: "Test Run",
        outcomes: %{"result" => "success", "count" => 42}
      }

      changeset = Run.changeset(%Run{}, attrs)
      assert changeset.valid?
      assert changeset.changes.title == "Test Run"
      assert changeset.changes.outcomes == %{"result" => "success", "count" => 42}
    end

    test "invalid changeset without user_id" do
      attrs = %{title: "Test Run"}
      changeset = Run.changeset(%Run{}, attrs)
      refute changeset.valid?
      assert %{user_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "valid changeset with nullable title" do
      attrs = %{user_id: 1, outcomes: %{"status" => "pending"}}
      changeset = Run.changeset(%Run{}, attrs)
      assert changeset.valid?
      refute Map.has_key?(changeset.changes, :title)
    end

    test "valid changeset with nullable outcomes" do
      attrs = %{user_id: 1, title: "Test Run"}
      changeset = Run.changeset(%Run{}, attrs)
      assert changeset.valid?
      refute Map.has_key?(changeset.changes, :outcomes)
    end
  end
end
