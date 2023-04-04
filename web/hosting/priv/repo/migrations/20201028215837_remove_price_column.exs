defmodule Hosting.Repo.Migrations.RemovePriceColumn do
  use Ecto.Migration

  def change do
    alter table(:items) do
      remove(:price)
    end
  end
end
