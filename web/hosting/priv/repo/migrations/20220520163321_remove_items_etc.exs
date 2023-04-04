defmodule Hosting.Repo.Migrations.RemoveItemsEtc do
  use Ecto.Migration

  def change do
    drop(table(:items), mode: :cascade)
    drop(table(:attributes), mode: :cascade)
    drop(table(:attribute_definitions), mode: :cascade)
  end
end
