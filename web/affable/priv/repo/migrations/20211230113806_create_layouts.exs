defmodule Affable.Repo.Migrations.CreateLayouts do
  use Ecto.Migration

  def change do
    create table(:layouts) do
      add(:site_id, references(:sites, on_delete: :delete_all), null: false)
      add(:name, :string, null: false)
      add(:grid_template_areas, :string, null: false, default: "")
      add(:grid_template_rows, :string, null: false, default: "")
      add(:grid_template_columns, :string, null: false, default: "")

      timestamps()
    end

    create(index(:layouts, [:site_id]))
  end
end
