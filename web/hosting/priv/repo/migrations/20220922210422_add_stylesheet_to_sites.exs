defmodule Hosting.Repo.Migrations.AddStylesheetToSites do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add(:stylesheet, :string, size: 50_000, default: "", null: false)
    end
  end
end
