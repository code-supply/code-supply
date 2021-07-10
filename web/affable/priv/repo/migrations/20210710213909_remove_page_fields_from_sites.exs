defmodule Affable.Repo.Migrations.RemovePageFieldsFromSites do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      remove(:page_subtitle)
    end
  end
end
