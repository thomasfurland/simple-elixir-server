defmodule SimpleElixirServer.RunDataStoreTest do
  use ExUnit.Case, async: false

  alias SimpleElixirServer.RunDataStore

  @test_run_id 99999
  @sample_csv_data """
  date,open,high,low,close,volume
  2024-01-01,100.0,110.0,95.0,105.0,1000000
  2024-01-02,105.0,115.0,100.0,112.0,1200000
  """

  setup do
    on_exit(fn ->
      RunDataStore.delete(@test_run_id)
    end)
  end

  describe "storage_path/0" do
    test "returns a valid directory path" do
      path = RunDataStore.storage_path()
      assert is_binary(path)
      assert String.contains?(path, "run_data")
    end

    test "creates the directory if it doesn't exist" do
      path = RunDataStore.storage_path()
      assert File.dir?(path)
    end
  end

  describe "write/2" do
    test "writes CSV content to file" do
      assert :ok = RunDataStore.write(@test_run_id, @sample_csv_data)
      assert RunDataStore.exists?(@test_run_id)
    end

    test "overwrites existing file" do
      RunDataStore.write(@test_run_id, "old data")
      RunDataStore.write(@test_run_id, @sample_csv_data)

      {:ok, contents} = RunDataStore.read(@test_run_id)
      assert contents == @sample_csv_data
    end

    test "returns error for empty content" do
      assert {:error, :empty_content} = RunDataStore.write(@test_run_id, "")
    end

    test "returns error for whitespace-only content" do
      assert {:error, :empty_content} = RunDataStore.write(@test_run_id, "   \n  ")
    end
  end

  describe "read/1" do
    test "reads existing CSV file" do
      RunDataStore.write(@test_run_id, @sample_csv_data)
      assert {:ok, contents} = RunDataStore.read(@test_run_id)
      assert contents == @sample_csv_data
    end

    test "returns error for non-existent file" do
      assert {:error, :not_found} = RunDataStore.read(@test_run_id)
    end
  end

  describe "delete/1" do
    test "deletes existing file" do
      RunDataStore.write(@test_run_id, @sample_csv_data)
      assert RunDataStore.exists?(@test_run_id)

      assert :ok = RunDataStore.delete(@test_run_id)
      refute RunDataStore.exists?(@test_run_id)
    end

    test "returns ok for non-existent file" do
      assert :ok = RunDataStore.delete(@test_run_id)
    end
  end

  describe "exists?/1" do
    test "returns true when file exists" do
      RunDataStore.write(@test_run_id, @sample_csv_data)
      assert RunDataStore.exists?(@test_run_id)
    end

    test "returns false when file doesn't exist" do
      refute RunDataStore.exists?(@test_run_id)
    end
  end

  describe "multiple runs" do
    test "can store data for multiple runs independently" do
      run_id_1 = 11111
      run_id_2 = 22222

      data_1 = "run 1 data"
      data_2 = "run 2 data"

      RunDataStore.write(run_id_1, data_1)
      RunDataStore.write(run_id_2, data_2)

      assert {:ok, ^data_1} = RunDataStore.read(run_id_1)
      assert {:ok, ^data_2} = RunDataStore.read(run_id_2)

      RunDataStore.delete(run_id_1)
      RunDataStore.delete(run_id_2)
    end
  end
end
