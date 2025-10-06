defmodule SimpleJobProcessor.Workers.DataProcessing do
  use Oban.Worker, queue: :data_processing

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"run_id" => run_id}}) do
    case SimpleElixirServer.Runs.find(run_id) do
      {:ok, run} ->
        updated_outcomes = Map.put(run.outcomes, "executed_by", "data_processing")
        SimpleElixirServer.Runs.update(run, %{outcomes: updated_outcomes})
        :ok

      {:error, :not_found} ->
        {:error, "Run not found"}
    end
  end

  def perform(_job), do: :ok
end
