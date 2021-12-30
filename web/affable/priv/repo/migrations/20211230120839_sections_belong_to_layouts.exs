defmodule Affable.Repo.Migrations.SectionsBelongToLayouts do
  use Ecto.Migration

  def change do
    alter table(:sections) do
      add(:layout_id, references(:layouts, on_delete: :nothing))
    end
  end
end
