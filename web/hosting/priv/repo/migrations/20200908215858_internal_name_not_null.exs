defmodule Hosting.Repo.Migrations.InternalNameNotNull do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      modify(:internal_name, :string, null: false)
    end
  end
end
