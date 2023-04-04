defmodule Hosting.Repo.Migrations.AddPathToPages do
  use Ecto.Migration

  def change do
    alter table(:pages) do
      add(:path, :string, null: false, default: "/")
    end
  end
end
