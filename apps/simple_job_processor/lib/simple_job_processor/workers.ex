defmodule SimpleJobProcessor.Workers do
  @moduledoc """
  Behavior for creating standardized Oban workers for the Event Analysis Engine.

  This module injects a `perform/1` function that:
  - Accepts `run_id` and `filepath` arguments
  - Loads and parses CSV candlestick data
  - Iterates through each row, calling the implementing module's `analyze/2` callback
  - Collects results and updates the run with outcomes

  ## Usage

      defmodule MyWorker do
        use SimpleJobProcessor.Workers
        
        @impl true
        def analyze(row, accumulated) do
          # Process the row and return updated accumulated data
          Map.update(accumulated, :count, 1, &(&1 + 1))
        end
      end
  """

  @callback analyze(row :: map(), accumulated :: map()) :: map()

  defmacro __using__(opts) do
    quote do
      use Oban.Worker, unquote(opts)

      @behaviour SimpleJobProcessor.Workers

      @impl Oban.Worker
      def perform(%Oban.Job{args: %{"run_id" => run_id, "filepath" => filepath}}) do
        with {:ok, run} <- SimpleElixirServer.Runs.find(run_id),
             {:ok, csv_path} <- resolve_filepath(filepath),
             {:ok, results} <- process_csv(csv_path) do
          outcomes =
            run.outcomes
            |> Kernel.||(%{})
            |> Map.merge(%{
              "worker" => __MODULE__ |> to_string() |> String.split(".") |> List.last(),
              "status" => "completed",
              "results" => results,
              "filepath" => filepath,
              "rows_processed" => Map.get(results, "rows_processed", 0)
            })

          case SimpleElixirServer.Runs.update(run, %{outcomes: outcomes}) do
            {:ok, _updated_run} -> :ok
            {:error, reason} -> {:error, "Failed to update run: #{inspect(reason)}"}
          end
        else
          {:error, :not_found} ->
            mark_failed(run_id, "Run not found")

          {:error, :file_not_found} ->
            mark_failed(run_id, "CSV file not found at path: #{filepath}")

          {:error, reason} when is_binary(reason) ->
            mark_failed(run_id, reason)

          {:error, reason} ->
            mark_failed(run_id, "Processing failed: #{inspect(reason)}")
        end
      end

      def perform(_job), do: {:error, "Invalid job arguments: expected run_id and filepath"}

      defp resolve_filepath(filepath) do
        base_path = Application.app_dir(:simple_job_processor, "priv/data")
        full_path = Path.join(base_path, filepath)

        if File.exists?(full_path) do
          {:ok, full_path}
        else
          {:error, :file_not_found}
        end
      end

      defp process_csv(csv_path) do
        csv_path
        |> File.stream!()
        |> CSV.decode(headers: true)
        |> Enum.reduce_while({:ok, %{}}, fn
          {:ok, row}, {:ok, accumulated} ->
            try do
              updated = analyze(row, accumulated)
              rows_count = Map.get(updated, "rows_processed", 0) + 1
              {:cont, {:ok, Map.put(updated, "rows_processed", rows_count)}}
            rescue
              e ->
                {:halt, {:error, "Error in analyze/2 callback: #{Exception.message(e)}"}}
            end

          {:error, reason}, _acc ->
            {:halt, {:error, "CSV parsing error: #{inspect(reason)}"}}
        end)
      rescue
        e in File.Error ->
          {:error, "File error: #{Exception.message(e)}"}

        e ->
          {:error, "Unexpected error: #{Exception.message(e)}"}
      end

      defp mark_failed(run_id, message) do
        case SimpleElixirServer.Runs.find(run_id) do
          {:ok, run} ->
            outcomes =
              run.outcomes
              |> Kernel.||(%{})
              |> Map.merge(%{
                "worker" => __MODULE__ |> to_string() |> String.split(".") |> List.last(),
                "status" => "failed",
                "error" => message
              })

            SimpleElixirServer.Runs.update(run, %{outcomes: outcomes})
            {:error, message}

          {:error, _} ->
            {:error, message}
        end
      end

      defoverridable perform: 1
    end
  end
end
