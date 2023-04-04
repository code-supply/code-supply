defmodule Hosting.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add(:name, :string, null: false)
      add(:description, :text)
      add(:url, :string)
      add(:image_url, :string)
      add(:price, :decimal)
      add(:position, :integer)
      add(:site_id, references(:sites, on_delete: :delete_all))

      timestamps()
    end

    create(index(:items, [:site_id]))
    create(unique_index(:items, [:site_id, :position]))
  end
end
