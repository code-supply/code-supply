defmodule Hosting.Repo.Migrations.ExtendStylesheet do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      modify(:stylesheet, :string, size: 1_000_000, default: "", null: false)
    end
  end
end
