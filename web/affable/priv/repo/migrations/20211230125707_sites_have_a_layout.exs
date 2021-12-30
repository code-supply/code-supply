defmodule Affable.Repo.Migrations.SitesHaveALayout do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add(:layout_id, references(:layouts, on_delete: :restrict))
    end
  end
end
