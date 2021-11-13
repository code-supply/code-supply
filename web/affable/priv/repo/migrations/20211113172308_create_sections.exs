defmodule Affable.Repo.Migrations.CreateSections do
  use Ecto.Migration

  def change do
    create table(:sections) do
      add(:name, :string, null: false)
      add(:element, :string, null: false)
      add(:background_colour, :string, null: false)
      add(:text_colour, :string, null: false)
      add(:content, :text, null: false)
      add(:page_id, references(:pages, on_delete: :delete_all), null: false)
      add(:image_id, references(:assets, on_delete: :restrict))

      timestamps()
    end

    create(index(:sections, [:page_id]))
    create(index(:sections, [:image_id]))
    create(unique_index(:sections, [:page_id, :name]))
  end
end
