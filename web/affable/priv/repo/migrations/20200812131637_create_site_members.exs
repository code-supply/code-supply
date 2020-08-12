defmodule Affable.Repo.Migrations.CreateSiteMembers do
  use Ecto.Migration

  def change do
    create table(:site_members) do
      add(:user_id, references(:users, on_delete: :delete_all))
      add(:site_id, references(:sites, on_delete: :delete_all))

      timestamps()
    end

    create(index(:site_members, [:user_id]))
    create(index(:site_members, [:site_id]))
  end
end
