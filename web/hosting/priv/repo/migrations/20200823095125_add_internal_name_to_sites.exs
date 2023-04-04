defmodule Hosting.Repo.Migrations.AddInternalNameToSites do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add(:internal_name, :string)
    end

    create(unique_index(:sites, [:internal_name]))
  end
end
