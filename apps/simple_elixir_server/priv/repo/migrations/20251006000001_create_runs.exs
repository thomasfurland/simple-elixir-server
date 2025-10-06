defmodule SimpleElixirServer.Repo.Migrations.CreateRuns do
  use Ecto.Migration

  def change do
    create table(:runs) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :outcomes, :json
      add :title, :string

      timestamps()
    end

    create index(:runs, [:user_id])
  end
end
