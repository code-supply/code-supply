defmodule Affable.Repo.Migrations.CreateAssets do
  use Ecto.Migration

  def change do
    create table(:assets) do
      add :url, :string
      add :site_id, references(:sites, on_delete: :nothing)

      timestamps()
    end

    create index(:assets, [:site_id])
  end
end
