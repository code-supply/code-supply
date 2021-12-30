defmodule Affable.Repo.Migrations.SectionsAllowedNullPages do
  use Ecto.Migration

  def change do
    alter table(:sections) do
      modify(:page_id, :integer, null: true)
    end
  end
end
