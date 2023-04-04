defmodule Hosting.Repo.Migrations.RemovePageHeaders do
  use Ecto.Migration

  def change do
    alter(table(:pages)) do
      remove(:header_text)
      remove(:header_background_colour)
      remove(:header_text_colour)
      remove(:header_image_id)
    end
  end
end
