defmodule Affable.Repo.Migrations.RemoveSiteLogo do
  use Ecto.Migration

  def change do
    alter(table(:sites)) do
      remove(:site_logo_id)
    end
  end
end
