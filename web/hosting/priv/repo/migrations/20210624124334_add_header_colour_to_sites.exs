defmodule Hosting.Repo.Migrations.AddHeaderColourToSites do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      add(:header_background_colour, :string, size: 6, null: false, default: "3B82F6")
      add(:header_text_colour, :string, size: 6, null: false, default: "FFFFFF")
    end
  end
end
