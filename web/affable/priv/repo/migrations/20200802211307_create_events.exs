defmodule Affable.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add(:description, :text)
      add(:event_type, :string, null: false)
      add(:user_id, references(:users, on_delete: :nothing))
      add(:domain_id, references(:domains, on_delete: :nothing))

      timestamps()
    end

    create(index(:events, [:event_type]))
    create(index(:events, [:user_id]))
    create(index(:events, [:domain_id]))
  end
end
