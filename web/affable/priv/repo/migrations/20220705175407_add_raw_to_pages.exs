defmodule Affable.Repo.Migrations.AddRawToPages do
  use Ecto.Migration

  def change do
    alter table(:pages) do
      add(:raw, :string, size: 50_000, default: "", null: false)
    end
  end
end
