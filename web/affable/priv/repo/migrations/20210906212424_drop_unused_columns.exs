defmodule Affable.Repo.Migrations.DropUnusedColumns do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      remove(:cta_background_colour)
      remove(:cta_text)
      remove(:cta_text_colour)
      remove(:header_background_colour)
      remove(:header_image_id)
      remove(:header_text_colour)
      remove(:text)
    end
  end
end
