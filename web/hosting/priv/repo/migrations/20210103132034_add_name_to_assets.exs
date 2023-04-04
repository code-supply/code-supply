defmodule Hosting.Repo.Migrations.AddNameToAssets do
  use Ecto.Migration

  def change do
    alter table(:assets) do
      add(:name, :string, null: false)
    end
  end
end
