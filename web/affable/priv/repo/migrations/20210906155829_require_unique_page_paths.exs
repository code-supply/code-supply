defmodule Affable.Repo.Migrations.RequireUniquePagePaths do
  use Ecto.Migration

  def change do
    create(unique_index(:pages, [:site_id, :path]))
  end
end
