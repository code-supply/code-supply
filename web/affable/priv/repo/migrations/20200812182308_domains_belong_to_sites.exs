defmodule Affable.Repo.Migrations.DomainsBelongToSites do
  use Ecto.Migration

  def change do
    alter table(:domains) do
      add(:site_id, references(:sites, on_delete: :delete_all))
    end
  end
end
