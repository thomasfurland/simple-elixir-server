defmodule SimpleElixirServer.RunsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SimpleElixirServer.Runs` context.
  """

  alias SimpleElixirServer.Runs

  def valid_run_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      user_id: attrs[:user_id] || raise("user_id is required"),
      title: "Test Run #{System.unique_integer([:positive])}",
      outcomes: %{"status" => "success", "count" => 42}
    })
  end

  def run_fixture(attrs \\ %{}) do
    {:ok, run} =
      attrs
      |> valid_run_attributes()
      |> Runs.create()

    run
  end
end
