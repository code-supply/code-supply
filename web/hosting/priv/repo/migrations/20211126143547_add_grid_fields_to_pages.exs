defmodule Hosting.Repo.Migrations.AddGridFieldsToPages do
  use Ecto.Migration

  def change do
    alter table(:pages) do
      add(:grid_template_areas, :string, null: false, default: "")
      add(:grid_template_rows, :string, null: false, default: "")
      add(:grid_template_columns, :string, null: false, default: "")
    end
  end
end
