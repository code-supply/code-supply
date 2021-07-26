defmodule Affable.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages) do
      add(:title, :string, null: false)
      add(:meta_description, :string, null: false)
      add(:header_text, :text, null: false)
      add(:header_background_colour, :string, null: false)
      add(:header_text_colour, :string, null: false)
      add(:text, :text, null: false)
      add(:cta_background_colour, :string, null: false)
      add(:cta_text_colour, :string, null: false)
      add(:cta_text, :string, null: false)
      add(:site_id, references(:sites, on_delete: :delete_all))
      add(:header_image_id, references(:assets, on_delete: :restrict))

      timestamps()
    end

    create(index(:pages, [:site_id]))
    create(index(:pages, [:header_image_id]))
  end
end
