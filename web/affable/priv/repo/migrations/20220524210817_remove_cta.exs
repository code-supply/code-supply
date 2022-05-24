defmodule Affable.Repo.Migrations.RemoveCta do
  use Ecto.Migration

  def change do
    alter(table(:pages)) do
      remove(:cta_text)
      remove(:cta_background_colour)
      remove(:cta_text_colour)
    end
  end
end
