defmodule Affable.Repo.Migrations.RequireNonNullInternalNames do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      modify(:internal_hostname, :string, null: false)
    end
  end
end
