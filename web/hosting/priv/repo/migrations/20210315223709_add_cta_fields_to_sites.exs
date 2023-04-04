defmodule Hosting.Repo.Migrations.AddCtaFieldsToSites do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add(:cta_background_colour, :string, size: 6, null: false, default: "059669")
      add(:cta_text_colour, :string, size: 6, null: false, default: "FFFFFF")
      add(:cta_text, :string, null: false, default: "Go")
    end
  end
end
