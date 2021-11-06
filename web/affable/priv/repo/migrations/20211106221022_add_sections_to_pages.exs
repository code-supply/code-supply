defmodule Affable.Repo.Migrations.AddSectionsToPages do
  use Ecto.Migration

  def change do
    alter table(:pages) do
      add(:sections, :map)
    end
  end
end
