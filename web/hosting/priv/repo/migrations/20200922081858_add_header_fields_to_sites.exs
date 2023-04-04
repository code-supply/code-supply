defmodule Hosting.Repo.Migrations.AddHeaderFieldsToSites do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add(:site_logo_url, :string)
      add(:header_image_url, :string)
      # we may eventually move these fields to a pages table, where we'll have
      # separate page titles
      add(:page_subtitle, :string)
      add(:text, :text)
    end
  end
end
