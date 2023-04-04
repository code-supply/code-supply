defmodule Hosting.Repo.Migrations.DropPublications do
  use Ecto.Migration

  def change do
    drop table(:publications)
  end
end
