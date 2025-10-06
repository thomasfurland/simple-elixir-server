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
  Returns a stream for the CSV data of a given run with headers guaranteed.

  ## Parameters
    - run_id: The ID of the run

  ## Examples

      iex> {:ok, stream} = stream(123)
      iex> Enum.take(stream, 1)
      ["date,open,high,low,close\\n"]

      iex> stream(999)
      {:error, :not_found}

  """
  def stream(run_id) do
    file_path = file_path(run_id)

    if File.exists?(file_path) do
      {:ok, file_path |> File.stream!() |> ensure_headers()}
    else
      {:error, :not_found}
    end
  end

  defp ensure_headers(csv_stream) do
    Stream.transform(csv_stream, :first_row, fn
      line, :first_row ->
        trimmed = String.trim(line)

        if has_header?(trimmed) do
          {[line], :pass_through}
        else
          header = generate_header(trimmed)
          {[header, line], :pass_through}
        end

      line, :pass_through ->
        {[line], :pass_through}
    end)
  end

  defp has_header?(line) do
    fields = String.split(line, ",") |> Enum.map(&String.trim/1)

    Enum.any?(fields, fn field ->
      case Float.parse(field) do
        {_float, ""} -> false
        :error -> true
        _ -> false
      end
    end)
  end

  defp generate_header(line) do
    field_count = line |> String.split(",") |> length()

    case field_count do
      4 -> "open,high,low,close"
      5 -> "open,high,low,close,volume"
      6 -> "timestamp,open,high,low,close,volume"
      _ -> "open,high,low,close"
    end
  end

  defp file_path(run_id) do
    Path.join(storage_path(), "#{run_id}.csv")
  end
end
