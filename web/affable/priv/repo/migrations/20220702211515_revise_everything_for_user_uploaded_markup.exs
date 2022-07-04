defmodule Affable.Repo.Migrations.ReviseEverythingForUserUploadedMarkup do
  use Ecto.Migration

  def change do
    alter table(:sites) do
      remove(:layout_id)
      remove(:custom_head_html)
    end

    alter table(:pages) do
      remove(:meta_description)
      remove(:text)
      remove(:grid_template_areas)
      remove(:grid_template_rows)
      remove(:grid_template_columns)
    end

    drop table(:sections)
    drop table(:layouts)
  end
end
