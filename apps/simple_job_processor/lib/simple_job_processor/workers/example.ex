defmodule SimpleJobProcessor.Workers.Example do
  @moduledoc """
  Example worker demonstrating the Workers behavior.

  This worker analyzes candlestick data and tracks:
  - Total candles processed
  - Average close price
  - Highest and lowest prices
  - Number of bullish vs bearish candles
  """

  use SimpleJobProcessor.Workers, queue: :example

  @impl SimpleJobProcessor.Workers
  def analyze(row, accumulated) do
    open = parse_float(row["open"])
    close = parse_float(row["close"])
    high = parse_float(row["high"])
    low = parse_float(row["low"])

    count = Map.get(accumulated, "count", 0) + 1
    total_close = Map.get(accumulated, "total_close", 0.0) + close

    bullish_count =
      if close > open,
        do: Map.get(accumulated, "bullish_count", 0) + 1,
        else: Map.get(accumulated, "bullish_count", 0)

    bearish_count =
      if close < open,
        do: Map.get(accumulated, "bearish_count", 0) + 1,
        else: Map.get(accumulated, "bearish_count", 0)

    %{
      "count" => count,
      "total_close" => total_close,
      "average_close" => total_close / count,
      "highest_price" => max(Map.get(accumulated, "highest_price", high), high),
      "lowest_price" => min(Map.get(accumulated, "lowest_price", low), low),
      "bullish_count" => bullish_count,
      "bearish_count" => bearish_count
    }
  end

  defp parse_float(value) when is_binary(value) do
    case Float.parse(value) do
      {float, _} -> float
      :error -> 0.0
    end
  end

  defp parse_float(value) when is_float(value), do: value
  defp parse_float(value) when is_integer(value), do: value * 1.0
  defp parse_float(_), do: 0.0
end
