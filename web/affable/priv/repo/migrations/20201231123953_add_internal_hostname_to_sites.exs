defmodule Affable.Repo.Migrations.AddInternalHostnameToSites do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add(:internal_hostname, :string, null: false)
    end

    create(unique_index(:sites, [:internal_hostname]))
  end
end
