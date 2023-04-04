defmodule Hosting.Repo.Migrations.DeletingSiteDeletesPublications do
  use Ecto.Migration

  def up do
    drop(constraint(:publications, "publications_site_id_fkey"))

    alter table(:publications) do
      modify(:site_id, references(:sites, on_delete: :delete_all, null: false))
    end
  end
end
