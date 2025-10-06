defmodule SimpleJobProcessor.Workers.EventAnalysis do
  use Oban.Worker, queue: :event_analysis

  @impl Oban.Worker
  def perform(_job) do
    :ok
  end
end
