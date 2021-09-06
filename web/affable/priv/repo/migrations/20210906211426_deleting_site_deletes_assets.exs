defmodule Affable.Repo.Migrations.DeletingSiteDeletesAssets do
  use Ecto.Migration

  def change do
    alter table(:assets) do
      modify(:site_id, references(:sites, on_delete: :delete_all),
        from: references(:sites, on_delete: :nothing)
      )
    end
  end
end
