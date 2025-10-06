defmodule SimpleJobProcessor.Workers.CsvHeaderTest do
  use ExUnit.Case, async: false
  use Oban.Testing, repo: SimpleElixirServer.Repo

  alias Ecto.Adapters.SQL
  alias SimpleJobProcessor.Workers.Example
  alias SimpleElixirServer.{Repo, Runs, RunDataStore}

  setup do
    :ok = SQL.Sandbox.checkout(Repo)

    on_exit(fn ->
      clean_test_files()
    end)
  end

  defp clean_test_files do
    RunDataStore.storage_path()
    |> File.ls!()
    |> Enum.reject(&(&1 == ".gitkeep"))
    |> Enum.each(fn file ->
      File.rm!(Path.join(RunDataStore.storage_path(), file))
    end)
  end

  describe "CSV without headers" do
    test "processes 4-column CSV (OHLC)" do
      Oban.Testing.with_testing_mode(:inline, fn ->
        csv_data = """
        100.0,110.0,95.0,105.0
        105.0,115.0,100.0,102.0
        """

        {:ok, user} =
          SimpleElixirServer.Accounts.register_user(%{
            email: "test1@example.com",
            password: "password123456"
          })

        {:ok, run} = Runs.create(%{user_id: user.id, title: "OHLC Test"})
        :ok = RunDataStore.write(run.id, csv_data)

        assert {:ok, %Oban.Job{state: "completed"}} =
                 Example.new(%{"run_id" => run.id}) |> Oban.insert()

        {:ok, updated_run} = Runs.find(run.id)
        assert updated_run.outcomes["status"] == "completed"
        assert updated_run.outcomes["rows_processed"] == 2
        assert updated_run.outcomes["results"]["count"] == 2
      end)
    end

    test "processes 5-column CSV (OHLCV)" do
      Oban.Testing.with_testing_mode(:inline, fn ->
        csv_data = """
        100.0,110.0,95.0,105.0,1000
        105.0,115.0,100.0,102.0,1200
        """

        {:ok, user} =
          SimpleElixirServer.Accounts.register_user(%{
            email: "test2@example.com",
            password: "password123456"
          })

        {:ok, run} = Runs.create(%{user_id: user.id, title: "OHLCV Test"})
        :ok = RunDataStore.write(run.id, csv_data)

        assert {:ok, %Oban.Job{state: "completed"}} =
                 Example.new(%{"run_id" => run.id}) |> Oban.insert()

        {:ok, updated_run} = Runs.find(run.id)
        assert updated_run.outcomes["status"] == "completed"
        assert updated_run.outcomes["rows_processed"] == 2
      end)
    end

    test "processes 6-column CSV (Timestamp + OHLCV)" do
      Oban.Testing.with_testing_mode(:inline, fn ->
        csv_data = """
        2025-01-01,100.0,110.0,95.0,105.0,1000
        2025-01-02,105.0,115.0,100.0,102.0,1200
        """

        {:ok, user} =
          SimpleElixirServer.Accounts.register_user(%{
            email: "test3@example.com",
            password: "password123456"
          })

        {:ok, run} = Runs.create(%{user_id: user.id, title: "Timestamp Test"})
        :ok = RunDataStore.write(run.id, csv_data)

        assert {:ok, %Oban.Job{state: "completed"}} =
                 Example.new(%{"run_id" => run.id}) |> Oban.insert()

        {:ok, updated_run} = Runs.find(run.id)
        assert updated_run.outcomes["status"] == "completed"
        assert updated_run.outcomes["rows_processed"] == 2
      end)
    end
  end

  describe "CSV with headers" do
    test "processes CSV with custom headers" do
      Oban.Testing.with_testing_mode(:inline, fn ->
        csv_data = """
        date,o,h,l,c,vol
        2025-01-01,100.0,110.0,95.0,105.0,1000
        2025-01-02,105.0,115.0,100.0,102.0,1200
        """

        {:ok, user} =
          SimpleElixirServer.Accounts.register_user(%{
            email: "test4@example.com",
            password: "password123456"
          })

        {:ok, run} = Runs.create(%{user_id: user.id, title: "Custom Headers Test"})
        :ok = RunDataStore.write(run.id, csv_data)

        assert {:ok, %Oban.Job{state: "completed"}} =
                 Example.new(%{"run_id" => run.id}) |> Oban.insert()

        {:ok, updated_run} = Runs.find(run.id)
        assert updated_run.outcomes["status"] == "completed"
        assert updated_run.outcomes["rows_processed"] == 2
      end)
    end

    test "processes standard CSV with headers" do
      Oban.Testing.with_testing_mode(:inline, fn ->
        csv_data = """
        timestamp,open,high,low,close,volume
        2025-01-01,100.0,110.0,95.0,105.0,1000
        2025-01-02,105.0,115.0,100.0,102.0,1200
        """

        {:ok, user} =
          SimpleElixirServer.Accounts.register_user(%{
            email: "test5@example.com",
            password: "password123456"
          })

        {:ok, run} = Runs.create(%{user_id: user.id, title: "Standard Headers Test"})
        :ok = RunDataStore.write(run.id, csv_data)

        assert {:ok, %Oban.Job{state: "completed"}} =
                 Example.new(%{"run_id" => run.id}) |> Oban.insert()

        {:ok, updated_run} = Runs.find(run.id)
        assert updated_run.outcomes["status"] == "completed"
        assert updated_run.outcomes["rows_processed"] == 2
      end)
    end
  end
end
