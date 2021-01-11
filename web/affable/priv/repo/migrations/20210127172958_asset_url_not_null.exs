defmodule Affable.Repo.Migrations.AssetUrlNotNull do
  use Ecto.Migration

  def change do
    alter table(:assets) do
      modify(:url, :string, null: false)
    end
  end
end
