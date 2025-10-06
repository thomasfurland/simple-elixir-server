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
        use SimpleJobProcessor.Workers, queue: :queue_name
        
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
      def perform(%Oban.Job{args: %{"run_id" => run_id}}) do
        with {:ok, run} <- SimpleElixirServer.Runs.find(run_id),
             {:ok, csv_stream} <- SimpleElixirServer.RunDataStore.stream(run_id),
             {:ok, results} <- process_csv(csv_stream) do
          outcomes =
            run.outcomes
            |> Kernel.||(%{})
            |> Map.merge(%{
              "worker" => __MODULE__ |> to_string() |> String.split(".") |> List.last(),
              "status" => "completed",
              "results" => results,
              "rows_processed" => Map.get(results, "rows_processed", 0)
            })

          case SimpleElixirServer.Runs.update(run, %{outcomes: outcomes}) do
            {:ok, _updated_run} -> :ok
            {:error, reason} -> {:error, "Failed to update run: #{inspect(reason)}"}
          end
        else
          {:error, :not_found} ->
            mark_failed(run_id, "Run or CSV data not found")

          {:error, reason} when is_binary(reason) ->
            mark_failed(run_id, reason)

          {:error, reason} ->
            mark_failed(run_id, "Processing failed: #{inspect(reason)}")
        end
      end

      def perform(_job), do: {:error, "Invalid job arguments: expected run_id"}

      defp process_csv(csv_stream) do
        csv_stream
        |> CSV.decode(headers: true)
        |> Enum.reduce_while({:ok, %{}, 0}, fn
          {:ok, row}, {:ok, accumulated, row_count} ->
            try do
              normalized_row = normalize_row(row)
              updated = analyze(normalized_row, accumulated)
              {:cont, {:ok, updated, row_count + 1}}
            rescue
              e ->
                {:halt, {:error, "Error in analyze/2 callback: #{Exception.message(e)}"}}
            end

          {:error, reason}, _acc ->
            {:halt, {:error, "CSV parsing error: #{inspect(reason)}"}}
        end)
        |> case do
          {:ok, results, row_count} -> {:ok, Map.put(results, "rows_processed", row_count)}
          error -> error
        end
      rescue
        e in File.Error ->
          {:error, "File error: #{Exception.message(e)}"}

        e ->
          {:error, "Unexpected error: #{Exception.message(e)}"}
      end

      defp normalize_row(row) do
        Map.new(row, fn {key, value} -> {key, parse_float(value)} end)
      end

      defp parse_float(value) when is_binary(value) do
        case Float.parse(value) do
          {float, _} -> float
          :error -> value
        end
      end

      defp parse_float(value) when is_float(value), do: value
      defp parse_float(value) when is_integer(value), do: value * 1.0
      defp parse_float(value), do: value

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
