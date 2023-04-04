defmodule Hosting.Repo.Migrations.DomainsBelongToSites do
  use Ecto.Migration

  def change do
    alter table(:domains) do
      add(:site_id, references(:sites, on_delete: :delete_all))
      remove(:user_id)
    end
  end
end
