defmodule Affable.Repo.Migrations.RequireSiteIdOnAssets do
  use Ecto.Migration

  def change do
    alter table(:assets) do
      modify(:site_id, :integer, null: false)
    end
  end
end
