defmodule SimpleJobProcessor.Workers.DataProcessing do
  use Oban.Worker, queue: :data_processing

  @impl Oban.Worker
  def perform(_job) do
    :ok
  end
end
