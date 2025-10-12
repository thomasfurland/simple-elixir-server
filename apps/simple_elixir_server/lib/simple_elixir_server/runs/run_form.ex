defmodule SimpleElixirServer.Runs.RunForm do
  @moduledoc """
  Embedded schema for validating run creation form inputs.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:title, :string)
    field(:job_runner, :string)
    field(:has_file, :boolean, default: false)
  end

  @doc """
  Creates a changeset for run form validation.
  """
  def changeset(form, attrs \\ %{}) do
    form
    |> cast(attrs, [:title, :job_runner, :has_file])
    |> validate_required([:job_runner], message: "Please select a job runner")
    |> validate_file_presence()
  end

  defp validate_file_presence(changeset) do
    has_file = get_field(changeset, :has_file, false)

    if has_file do
      changeset
    else
      add_error(changeset, :candlestick_data, "Please upload a CSV file")
    end
  end
end
