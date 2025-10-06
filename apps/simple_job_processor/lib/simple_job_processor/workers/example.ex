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
    open = row["open"]
    close = row["close"]
    high = row["high"]
    low = row["low"]

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
end
