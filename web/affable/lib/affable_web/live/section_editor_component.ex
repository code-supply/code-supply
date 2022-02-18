defmodule AffableWeb.SectionEditorComponent do
  use AffableWeb, :live_component
  import AffableWeb.EditorHelpers

  alias Affable.Sections
  alias Affable.Sites.Section

  @impl true
  def update(%{id: id, user: user, site: site}, socket) do
    section = Sections.get!(user, id)

    {:ok,
     assign(socket,
       user: user,
       section: section,
       asset_pairs: Enum.map(site.assets, &{&1.name, &1.id}),
       changeset: Section.changeset(section, %{}),
       elements: ~w(header nav main footer section)
     )}
  end

  @impl true
  def handle_event(
        "save",
        %{"section" => attrs},
        %{assigns: %{user: user, section: section}} = socket
      ) do
    with {:ok, section} <-
           Sections.get!(user, section.id)
           |> Sections.update(attrs) do
      send_update(AffableWeb.LayoutEditorComponent,
        id: section.layout_id,
        user: user,
        selected_section_id: section.id
      )

      {:noreply, assign(socket, section: section, changeset: Section.changeset(section, %{}))}
    else
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
