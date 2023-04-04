defmodule Hosting.Repo.Migrations.CreateAttributeDefinitions do
  use Ecto.Migration

  def change do
    create table(:attribute_definitions) do
      add(:name, :string, null: false)
      add(:type, :string, null: false, default: "text")
      add(:site_id, references(:sites, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:attribute_definitions, [:site_id]))
  end
end
