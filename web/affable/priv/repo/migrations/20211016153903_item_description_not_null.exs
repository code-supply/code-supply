defmodule Affable.Repo.Migrations.ItemDescriptionNotNull do
  use Ecto.Migration

  def change do
    alter table(:items) do
      modify(:description, :text, null: false, default: "")
    end
  end
end
