defmodule Hosting.Repo.Migrations.RemoveDefaultCtaValuesOnceMigrated do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      modify(:cta_background_colour, :string, size: 6, null: false)
      modify(:cta_text_colour, :string, size: 6, null: false)
      modify(:cta_text, :string, null: false)
    end
  end
end
