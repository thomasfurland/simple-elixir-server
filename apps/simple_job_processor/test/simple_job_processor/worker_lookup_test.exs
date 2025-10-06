defmodule SimpleJobProcessor.WorkerLookupTest do
  use ExUnit.Case, async: true

  alias SimpleJobProcessor.WorkerLookup

  describe "list_queues/0" do
    test "returns list of queue names as strings" do
      queues = WorkerLookup.list_queues()

      assert is_list(queues)
      assert "event_analysis" in queues
      assert "data_processing" in queues
    end
  end

  describe "queue_to_module/1" do
    test "returns module for valid queue name" do
      assert {:ok, SimpleJobProcessor.Workers.EventAnalysis} =
               WorkerLookup.queue_to_module("event_analysis")

      assert {:ok, SimpleJobProcessor.Workers.DataProcessing} =
               WorkerLookup.queue_to_module("data_processing")
    end

    test "returns error for non-existent queue" do
      assert {:error, message} = WorkerLookup.queue_to_module("non_existent")
      assert message =~ "not found or not an Oban worker"
      assert message =~ "SimpleJobProcessor.Workers.QueueName"
    end

    test "returns error for invalid module pattern" do
      assert {:error, message} = WorkerLookup.queue_to_module("invalid_queue")
      assert message =~ "not found or not an Oban worker"
    end
  end
end
