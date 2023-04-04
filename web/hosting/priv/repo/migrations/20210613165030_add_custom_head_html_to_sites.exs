defmodule Hosting.Repo.Migrations.AddCustomHeadHtmlToSites do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add(:custom_head_html, :text, null: false, default: "")
    end
  end
end
