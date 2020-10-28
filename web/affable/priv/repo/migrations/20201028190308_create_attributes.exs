defmodule Affable.Repo.Migrations.CreateAttributes do
  use Ecto.Migration

  def change do
    create table(:attributes) do
      add(:value, :string)
      add(:item_id, references(:items, on_delete: :delete_all))
      add(:definition_id, references(:attribute_definitions, on_delete: :delete_all))

      timestamps()
    end

    create(index(:attributes, [:item_id]))
    create(index(:attributes, [:definition_id]))
  end
end
