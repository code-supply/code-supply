defmodule Hosting.Repo.Migrations.AddApiKeyToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add(:api_key, :string, null: true)
    end
  end
end
