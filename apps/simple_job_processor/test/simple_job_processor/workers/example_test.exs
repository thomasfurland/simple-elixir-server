defmodule SimpleJobProcessor.Workers.ExampleTest do
  use ExUnit.Case, async: false
  use Oban.Testing, repo: SimpleElixirServer.Repo

  alias Ecto.Adapters.SQL
  alias SimpleJobProcessor.Workers.Example
  alias SimpleElixirServer.{Repo, Runs, RunDataStore}

  @sample_csv_data """
  timestamp,open,high,low,close,volume
  2025-01-01 00:00:00,100.0,110.0,95.0,105.0,1000
  2025-01-02 00:00:00,105.0,115.0,100.0,102.0,1200
  2025-01-03 00:00:00,102.0,108.0,98.0,100.0,1100
  """

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

  describe "analyze/2" do
    test "processes a single candlestick row with floats" do
      row = %{
        "timestamp" => "2025-01-01 00:00:00",
        "open" => 100.0,
        "high" => 110.0,
        "low" => 95.0,
        "close" => 105.0,
        "volume" => 1000.0
      }

      result = Example.analyze(row, %{})

      assert result["count"] == 1
      assert result["average_close"] == 105.0
      assert result["highest_price"] == 110.0
      assert result["lowest_price"] == 95.0
      assert result["bullish_count"] == 1
      assert result["bearish_count"] == 0
    end

    test "accumulates data across multiple rows" do
      row1 = %{"open" => 100.0, "high" => 110.0, "low" => 95.0, "close" => 105.0}
      row2 = %{"open" => 105.0, "high" => 115.0, "low" => 100.0, "close" => 102.0}

      accumulated = Example.analyze(row1, %{})
      result = Example.analyze(row2, accumulated)

      assert result["count"] == 2
      assert result["average_close"] == 103.5
      assert result["highest_price"] == 115.0
      assert result["lowest_price"] == 95.0
      assert result["bullish_count"] == 1
      assert result["bearish_count"] == 1
    end

    test "tracks bullish and bearish candles correctly" do
      bullish_row = %{"open" => 100.0, "high" => 110.0, "low" => 95.0, "close" => 105.0}
      bearish_row = %{"open" => 105.0, "high" => 110.0, "low" => 95.0, "close" => 100.0}
      doji_row = %{"open" => 100.0, "high" => 105.0, "low" => 95.0, "close" => 100.0}

      acc1 = Example.analyze(bullish_row, %{})
      acc2 = Example.analyze(bearish_row, acc1)
      result = Example.analyze(doji_row, acc2)

      assert result["bullish_count"] == 1
      assert result["bearish_count"] == 1
    end
  end

  describe "perform/1" do
    test "successfully processes CSV from RunDataStore" do
      Oban.Testing.with_testing_mode(:inline, fn ->
        {:ok, user} =
          SimpleElixirServer.Accounts.register_user(%{
            email: "test@example.com",
            password: "password123456"
          })

        {:ok, run} = Runs.create(%{user_id: user.id, title: "Test Run"})

        :ok = RunDataStore.write(run.id, @sample_csv_data)

        assert {:ok, %Oban.Job{state: "completed"}} =
                 Example.new(%{"run_id" => run.id}) |> Oban.insert()

        {:ok, updated_run} = Runs.find(run.id)
        assert updated_run.outcomes["status"] == "completed"
        assert updated_run.outcomes["worker"] == "Example"
        assert updated_run.outcomes["rows_processed"] == 3
        assert updated_run.outcomes["results"]["count"] == 3
        assert updated_run.outcomes["results"]["bullish_count"] == 1
        assert updated_run.outcomes["results"]["bearish_count"] == 2
      end)
    end

    test "handles missing run gracefully" do
      job = %Oban.Job{args: %{"run_id" => 99999}}
      assert {:error, message} = Example.perform(job)
      assert message =~ "Run or CSV data not found"
    end

    test "handles missing CSV data" do
      Oban.Testing.with_testing_mode(:inline, fn ->
        {:ok, user} =
          SimpleElixirServer.Accounts.register_user(%{
            email: "test2@example.com",
            password: "password123456"
          })

        {:ok, run} = Runs.create(%{user_id: user.id, title: "Test Run Without Data"})

        assert {:ok, %Oban.Job{state: "retryable"}} =
                 Example.new(%{"run_id" => run.id}) |> Oban.insert()

        {:ok, updated_run} = Runs.find(run.id)
        assert updated_run.outcomes["status"] == "failed"
        assert updated_run.outcomes["error"] =~ "not found"
      end)
    end

    test "handles invalid job arguments" do
      job = %Oban.Job{args: %{"invalid" => "args"}}
      assert {:error, message} = Example.perform(job)
      assert message =~ "Invalid job arguments"
    end

    test "processes CSV without headers" do
      Oban.Testing.with_testing_mode(:inline, fn ->
        csv_without_headers = """
        100.0,110.0,95.0,105.0
        105.0,115.0,100.0,102.0
        """

        {:ok, user} =
          SimpleElixirServer.Accounts.register_user(%{
            email: "test3@example.com",
            password: "password123456"
          })

        {:ok, run} = Runs.create(%{user_id: user.id, title: "No Headers Test"})
        :ok = RunDataStore.write(run.id, csv_without_headers)

        assert {:ok, %Oban.Job{state: "completed"}} =
                 Example.new(%{"run_id" => run.id}) |> Oban.insert()

        {:ok, updated_run} = Runs.find(run.id)
        assert updated_run.outcomes["status"] == "completed"
        assert updated_run.outcomes["rows_processed"] == 2
      end)
    end
  end
end
