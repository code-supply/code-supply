defmodule Hosting.Repo.Migrations.CreatePublications do
  use Ecto.Migration

  def change do
    create table(:publications) do
      add(:data, :map)
      add(:site_id, references(:sites, on_delete: :nothing, null: false))

      timestamps()
    end

    create(index(:publications, [:site_id]))
  end
end
