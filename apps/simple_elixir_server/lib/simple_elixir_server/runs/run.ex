defmodule SimpleElixirServer.Runs.Run do
  use Ecto.Schema
  import Ecto.Changeset

  schema "runs" do
    field :outcomes, :map
    field :title, :string
    belongs_to :user, SimpleElixirServer.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(run, attrs) do
    run
    |> cast(attrs, [:user_id, :outcomes, :title])
    |> validate_required([:user_id])
    |> foreign_key_constraint(:user_id)
  end
end
