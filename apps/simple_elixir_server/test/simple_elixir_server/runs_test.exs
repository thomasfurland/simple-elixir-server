defmodule SimpleElixirServer.RunsTest do
  use SimpleElixirServer.DataCase

  alias SimpleElixirServer.Runs
  alias SimpleElixirServer.Runs.Run

  import SimpleElixirServer.AccountsFixtures
  import SimpleElixirServer.RunsFixtures

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

  describe "create/1" do
    test "creates a run with valid attributes" do
      user = user_fixture()
      attrs = %{user_id: user.id, title: "New Run", outcomes: %{"status" => "pending"}}

      assert {:ok, %Run{} = run} = Runs.create(attrs)
      assert run.user_id == user.id
      assert run.title == "New Run"
      assert run.outcomes == %{"status" => "pending"}
    end

    test "returns error changeset with invalid attributes" do
      assert {:error, %Ecto.Changeset{}} = Runs.create(%{})
    end

    test "creates a run with only required fields" do
      user = user_fixture()
      attrs = %{user_id: user.id}

      assert {:ok, %Run{} = run} = Runs.create(attrs)
      assert run.user_id == user.id
      assert is_nil(run.title)
      assert is_nil(run.outcomes)
    end
  end

  describe "find/1" do
    test "returns run with preloaded user when id exists" do
      user = user_fixture()
      run = run_fixture(user_id: user.id)

      assert {:ok, %Run{} = found_run} = Runs.find(run.id)
      assert found_run.id == run.id
      assert found_run.user.id == user.id
      assert found_run.user.email == user.email
    end

    test "returns error when id does not exist" do
      assert {:error, :not_found} = Runs.find(-1)
    end
  end

  describe "find_all/1" do
    test "returns all runs with preloaded users" do
      user1 = user_fixture()
      user2 = user_fixture()
      run1 = run_fixture(user_id: user1.id)
      run2 = run_fixture(user_id: user2.id)

      assert {:ok, runs} = Runs.find_all()
      assert length(runs) >= 2

      run_ids = Enum.map(runs, & &1.id)
      assert run1.id in run_ids
      assert run2.id in run_ids

      assert Enum.all?(runs, fn run ->
               Ecto.assoc_loaded?(run.user)
             end)
    end

    test "filters runs by user_id" do
      user1 = user_fixture()
      user2 = user_fixture()
      run1 = run_fixture(user_id: user1.id)
      _run2 = run_fixture(user_id: user2.id)

      assert {:ok, runs} = Runs.find_all(%{user_id: user1.id})
      assert length(runs) == 1
      assert hd(runs).id == run1.id
      assert hd(runs).user.id == user1.id
    end

    test "returns empty list when no runs match filter" do
      assert {:ok, runs} = Runs.find_all(%{user_id: -1})
      assert runs == []
    end

    test "ignores unknown filter keys" do
      user = user_fixture()
      run = run_fixture(user_id: user.id)

      assert {:ok, runs} = Runs.find_all(%{unknown_key: "value"})
      assert length(runs) >= 1
      assert Enum.any?(runs, fn r -> r.id == run.id end)
    end
  end

  describe "update/2" do
    test "updates run with valid attributes" do
      user = user_fixture()
      run = run_fixture(user_id: user.id, title: "Original")

      assert {:ok, %Run{} = updated_run} =
               Runs.update(run, %{title: "Updated", outcomes: %{"new" => "data"}})

      assert updated_run.id == run.id
      assert updated_run.title == "Updated"
      assert updated_run.outcomes == %{"new" => "data"}
    end

    test "does not update user_id even if provided" do
      user1 = user_fixture()
      user2 = user_fixture()
      run = run_fixture(user_id: user1.id)

      assert {:ok, %Run{} = updated_run} = Runs.update(run, %{user_id: user2.id, title: "Test"})
      assert updated_run.user_id == user1.id
      assert updated_run.title == "Test"
    end

    test "allows setting title to nil" do
      user = user_fixture()
      run = run_fixture(user_id: user.id, title: "Original")

      assert {:ok, %Run{} = updated_run} = Runs.update(run, %{title: nil})
      assert is_nil(updated_run.title)
    end

    test "allows setting outcomes to nil" do
      user = user_fixture()
      run = run_fixture(user_id: user.id, outcomes: %{"data" => "value"})

      assert {:ok, %Run{} = updated_run} = Runs.update(run, %{outcomes: nil})
      assert is_nil(updated_run.outcomes)
    end
  end

  describe "delete/1" do
    test "deletes the run" do
      user = user_fixture()
      run = run_fixture(user_id: user.id)

      assert {:ok, %Run{}} = Runs.delete(run)
      assert {:error, :not_found} = Runs.find(run.id)
    end

    test "returns deleted run data" do
      user = user_fixture()
      run = run_fixture(user_id: user.id, title: "To Delete")

      assert {:ok, %Run{} = deleted_run} = Runs.delete(run)
      assert deleted_run.id == run.id
      assert deleted_run.title == "To Delete"
    end
  end
end
