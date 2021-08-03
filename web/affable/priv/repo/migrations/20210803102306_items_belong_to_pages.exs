defmodule Affable.Repo.Migrations.ItemsBelongToPages do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add(:page_id, references(:pages, on_delete: :delete_all, null: false))
    end
  end
end
