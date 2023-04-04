defmodule Hosting.Repo.Migrations.AssetUrlsBecomeIds do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add(:site_logo_id, references(:assets, on_delete: :restrict))
      add(:header_image_id, references(:assets, on_delete: :restrict))
      remove(:site_logo_url)
      remove(:header_image_url)
    end
  end
end
