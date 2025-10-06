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

  @doc """
  Validates that CSV content has the correct format (4, 5, or 6 columns per row).
  Headers are optional and will be detected and skipped.

  ## Parameters
    - contents: The CSV content as a string

  ## Returns
    - :ok if valid
    - {:error, message} if invalid

  ## Examples

      iex> validate_csv("100,110,95,105\\n101,111,96,106")
      :ok

      iex> validate_csv("timestamp,100,110,95,105,1000\\n123456,101,111,96,106,2000")
      :ok

      iex> validate_csv("100,110,95")
      {:error, "Invalid CSV format. Expected 4, 5, or 6 columns per row. Found 3 columns. Format: 4 columns (OHLC), 5 columns (OHLCV), or 6 columns (timestamp, OHLCV). Headers are optional."}

  """
  def validate_csv(contents) when is_binary(contents) do
    if String.trim(contents) == "" do
      {:error, "CSV file is empty"}
    else
      lines =
        contents
        |> String.split(["\n", "\r\n"], trim: true)
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == ""))

      if Enum.empty?(lines) do
        {:error, "CSV file is empty"}
      else
        validate_rows(lines)
      end
    end
  end

  defp validate_rows(lines) do
    lines
    |> Enum.with_index(1)
    |> Enum.reduce_while(:ok, fn {line, line_num}, _acc ->
      case validate_row(line, line_num) do
        :ok -> {:cont, :ok}
        {:skip_header, _} -> {:cont, :ok}
        {:error, _} = error -> {:halt, error}
      end
    end)
  end

  defp validate_row(line, line_num) do
    columns = String.split(line, ",", trim: false)
    column_count = length(columns)

    cond do
      column_count in [4, 5, 6] ->
        if line_num == 1 and is_header_row?(columns) do
          {:skip_header, line_num}
        else
          :ok
        end

      true ->
        {:error,
         "Invalid CSV format. Expected 4, 5, or 6 columns per row. Found #{column_count} columns on line #{line_num}. Format: 4 columns (OHLC), 5 columns (OHLCV), or 6 columns (timestamp, OHLCV). Headers are optional."}
    end
  end

  defp file_path(run_id) do
    Path.join(storage_path(), "#{run_id}.csv")
  end
end
