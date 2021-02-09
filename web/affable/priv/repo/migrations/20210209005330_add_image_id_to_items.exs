defmodule Affable.Repo.Migrations.AddImageIdToItems do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add(:image_id, references(:assets, on_delete: :restrict))
    end
  end
end
