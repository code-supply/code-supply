defmodule Affable.Repo.Migrations.RequireAttributesToHaveDefinitions do
  use Ecto.Migration

  def change do
    alter table(:attributes) do
      modify(:definition_id, :integer, null: false)
    end
  end
end
