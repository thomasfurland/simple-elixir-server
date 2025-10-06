defmodule SimpleJobProcessor.Workers.ExampleTest do
  use ExUnit.Case, async: false

  alias SimpleJobProcessor.Workers.Example

  describe "analyze/2" do
    test "processes a single candlestick row correctly" do
      row = %{
        "timestamp" => "2025-01-01 00:00:00",
        "open" => "100.0",
        "high" => "110.0",
        "low" => "95.0",
        "close" => "105.0",
        "volume" => "1000"
      }

      result = Example.analyze(row, %{})

      assert result["count"] == 1
      assert result["average_close"] == 105.0
      assert result["highest_price"] == 110.0
      assert result["lowest_price"] == 95.0
      assert result["bullish_count"] == 1
      assert result["bearish_count"] == 0
    end

    test "accumulates data across multiple rows" do
      row1 = %{
        "open" => "100.0",
        "high" => "110.0",
        "low" => "95.0",
        "close" => "105.0"
      }

      row2 = %{
        "open" => "105.0",
        "high" => "115.0",
        "low" => "100.0",
        "close" => "102.0"
      }

      accumulated = Example.analyze(row1, %{})
      result = Example.analyze(row2, accumulated)

      assert result["count"] == 2
      assert result["average_close"] == 103.5
      assert result["highest_price"] == 115.0
      assert result["lowest_price"] == 95.0
      assert result["bullish_count"] == 1
      assert result["bearish_count"] == 1
    end

    test "tracks bullish and bearish candles correctly" do
      bullish_row = %{"open" => "100.0", "high" => "110.0", "low" => "95.0", "close" => "105.0"}
      bearish_row = %{"open" => "105.0", "high" => "110.0", "low" => "95.0", "close" => "100.0"}
      doji_row = %{"open" => "100.0", "high" => "105.0", "low" => "95.0", "close" => "100.0"}

      acc1 = Example.analyze(bullish_row, %{})
      acc2 = Example.analyze(bearish_row, acc1)
      result = Example.analyze(doji_row, acc2)

      assert result["bullish_count"] == 1
      assert result["bearish_count"] == 1
    end
  end
end
