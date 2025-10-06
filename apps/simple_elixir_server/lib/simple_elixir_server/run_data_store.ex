defmodule SimpleElixirServer.RunDataStore do
  @moduledoc """
  Manages local file storage for candlestick data associated with runs.
  Files are stored in priv/run_data/ and named by run_id.
  """

  @doc """
  Returns the absolute path to the run data storage directory.
  """
  def storage_path do
    Path.join(:code.priv_dir(:simple_elixir_server), "run_data")
  end

  @doc """
  Writes candlestick CSV data for a given run.

  ## Parameters
    - run_id: The ID of the run
    - contents: The CSV content as a string

  ## Examples

      iex> write(123, "date,open,high,low,close\\n2024-01-01,100,110,95,105")
      :ok

      iex> write(123, "")
      {:error, :empty_content}

  """
  def write(run_id, contents) when is_binary(contents) do
    if String.trim(contents) == "" do
      {:error, :empty_content}
    else
      file_path = file_path(run_id)
      File.write(file_path, contents)
    end
  end

  @doc """
  Reads candlestick CSV data for a given run.

  ## Parameters
    - run_id: The ID of the run

  ## Examples

      iex> read(123)
      {:ok, "date,open,high,low,close\\n..."}

      iex> read(999)
      {:error, :not_found}

  """
  def read(run_id) do
    file_path = file_path(run_id)

    case File.read(file_path) do
      {:ok, contents} -> {:ok, contents}
      {:error, :enoent} -> {:error, :not_found}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Deletes the candlestick data file for a given run.

  ## Parameters
    - run_id: The ID of the run

  ## Examples

      iex> delete(123)
      :ok

  """
  def delete(run_id) do
    file_path = file_path(run_id)

    case File.rm(file_path) do
      :ok -> :ok
      {:error, :enoent} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Checks if candlestick data exists for a given run.

  ## Parameters
    - run_id: The ID of the run

  ## Examples

      iex> exists?(123)
      true

      iex> exists?(999)
      false

  """
  def exists?(run_id) do
    file_path = file_path(run_id)
    File.exists?(file_path)
  end

  @doc """
  Returns a stream of candlestick data maps for a given run.

  Automatically detects and skips header rows, and converts CSV rows to maps
  with keys based on column count (4=OHLC, 5=OHLCV, 6=timestamp+OHLCV).

  ## Parameters
    - run_id: The ID of the run

  ## Examples

      iex> {:ok, stream} = stream(123)
      iex> Enum.take(stream, 1)
      [%{"open" => "100.0", "high" => "110.0", ...}]

      iex> stream(999)
      {:error, :not_found}

  """
  def stream(run_id) do
    file_path = file_path(run_id)

    if File.exists?(file_path) do
      stream =
        file_path
        |> File.stream!()
        |> CSV.decode(headers: false)
        |> Stream.transform(:first_row, fn
          {:ok, row_list}, :first_row ->
            if is_header_row?(row_list) do
              {[], :data_rows}
            else
              {[list_to_map(row_list)], :data_rows}
            end

          {:ok, row_list}, :data_rows ->
            {[list_to_map(row_list)], :data_rows}

          {:error, _reason}, state ->
            {[], state}
        end)

      {:ok, stream}
    else
      {:error, :not_found}
    end
  end

  defp is_header_row?(row_list) do
    Enum.any?(row_list, fn value ->
      trimmed = String.trim(value)

      case Float.parse(trimmed) do
        {_float, ""} -> false
        :error -> true
        _ -> false
      end
    end)
  end

  defp list_to_map(row_list) do
    keys = generate_keys(length(row_list))
    Enum.zip(keys, row_list) |> Map.new()
  end

  defp generate_keys(4), do: ["open", "high", "low", "close"]
  defp generate_keys(5), do: ["open", "high", "low", "close", "volume"]
  defp generate_keys(6), do: ["timestamp", "open", "high", "low", "close", "volume"]
  defp generate_keys(_), do: ["open", "high", "low", "close"]

  defp file_path(run_id) do
    Path.join(storage_path(), "#{run_id}.csv")
  end
end
