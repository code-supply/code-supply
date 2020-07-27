defmodule Affable.Repo.Migrations.CreateDomains do
  use Ecto.Migration

  def change do
    create table(:domains) do
      add(:name, :string, null: false)
      add(:user_id, references(:users, on_delete: :nothing), null: false)

      timestamps()
    end

    create(index(:domains, [:user_id]))
    create(unique_index(:domains, [:name]))
  end
end
