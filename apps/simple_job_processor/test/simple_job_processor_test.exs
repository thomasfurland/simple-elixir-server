defmodule SimpleJobProcessorTest do
  use ExUnit.Case
  doctest SimpleJobProcessor

  test "greets the world" do
    assert SimpleJobProcessor.hello() == :world
  end
end
