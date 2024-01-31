defmodule HostingWeb.UploaderLive do
  use HostingWeb, :live_view

  alias Hosting.Accounts
  alias Hosting.Sites
  alias Hosting.Uploader

  @accepted_types ~w(.css .gif .htm .html .jpeg .jpg .png .svg .txt .xml)

  @impl Phoenix.LiveView
  def mount(_params, %{"user_token" => token}, socket) do
    user = Accounts.get_user_by_session_token(token)

    {:ok,
     socket
     |> assign(user: user, grouped_entries: [])
     |> allow_upload(
       :files,
       external: &Uploader.presign_upload/2,
       accept: @accepted_types,
       max_entries: 1_000_000
     )}
  end

  @impl Phoenix.LiveView
  def handle_params(%{"site_id" => site_id} = _params, _b, socket) do
    {:noreply, assign(socket, site_id: site_id, form: to_form(%{"site_id" => site_id}))}
  end

  @impl Phoenix.LiveView
  def render(%{live_action: :new} = assigns) do
    ~H"""
    <div class="container">
      <h1>Throw it up</h1>
      <.form id="upload-form" for={@form} phx-submit="save" phx-change="validate">
        <.live_file_input
          upload={@uploads.files}
          webkitdirectory
          class={input_class(@grouped_entries)}
        />
        <.input field={@form[:site_id]} type="hidden" />
        <%= if Enum.any?(@grouped_entries) do %>
          <%= for entry <- @uploads.files.entries do %>
            <%= for err <- upload_errors(@uploads.files, entry) do %>
              <div class="alert alert-danger">
                <%= error_to_string(err) %>
              </div>
            <% end %>
          <% end %>
          <div>
            <ul>
              <%= for {group, entries} <- @grouped_entries do %>
                <li class="border-2 border-white my-4 p-4 shadow rounded bg-gray-200">
                  <h2 class="text-blue-600 text-2xl font-bold"><%= group %></h2>
                  <ul class="grid grid-cols-2">
                    <%= for entry <- entries do %>
                      <li class="p-4 m-2 bg-white font-mono">
                        <h3><%= format_path(entry.client_relative_path) %></h3>
                        <p class="text-right text-xs"><%= format_size(entry.client_size) %></p>
                        <p class="text-right text-xs">
                          <%= format_date(entry.client_last_modified) %>
                        </p>
                        <%= if group == "Images" do %>
                          <p>
                            <.live_img_preview entry={entry} />
                          </p>
                        <% end %>
                      </li>
                    <% end %>
                  </ul>
                </li>
              <% end %>
            </ul>
            <button class="btn btn-spaced" type="submit">Upload</button>
          </div>
        <% end %>
      </.form>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def handle_event("save", params, %{assigns: %{site_id: site_id, user: user}} = socket) do
    case uploaded_entries(socket, :files) do
      {[_ | _] = _complete, [] = _incomplete} ->
        site = Sites.get_site!(site_id)

        multi = deletions_multi(Ecto.Multi.new(), site.pages)

        multi =
          for entry <- consume_uploaded_entries(socket, :files, fn _, entry -> {:ok, entry} end),
              reduce: multi do
            m ->
              {:ok, downloaded_content} = storage().poll(Uploader.bucket_name(), entry.uuid)

              Uploader.record(
                m,
                site: site,
                user: user,
                entry: entry,
                params: params,
                content: downloaded_content
              )
          end

        {:ok, _} = Hosting.Repo.transaction(multi)

        {:noreply,
         socket
         |> put_flash(:info, "Upload complete!")
         |> redirect(external: url(~p"/sites"))}

      {_ = _complete, [_ | _] = _incomplete} ->
        {:noreply, socket}
    end
  end

  def handle_event("validate", _params, socket) do
    grouped_entries = Uploader.group_directory_entries(socket.assigns.uploads.files.entries)
    {:noreply, assign(socket, grouped_entries: grouped_entries)}
  end

  defp deletions_multi(multi, pages) do
    for page <- pages, reduce: multi do
      m ->
        Ecto.Multi.delete(m, "page#{page.id}", page)
    end
  end

  def error_to_string(:too_large), do: "One or more files is too large."

  def error_to_string(:not_accepted),
    do:
      "You have selected an unacceptable file type. Acceptable types are: #{Enum.join(@accepted_types, ", ")}."

  defp input_class(grouped_entries) do
    if Enum.any?(grouped_entries) do
      "hidden"
    else
      nil
    end
  end

  defp format_size(bytes) do
    case Size.humanize(bytes) do
      {:ok, size} ->
        size

      _ ->
        "Unknown"
    end
  end

  defp format_date(ms) when is_number(ms) do
    case DateTime.from_unix(floor(ms / 1000)) do
      {:ok, date} ->
        date

      {:error, :invalid_unix_time} ->
        "Couldn't parse #{ms}"
    end
  end

  defp format_path(path) do
    Uploader.strip_root(path)
  end

  defp storage do
    Application.get_env(:hosting, :storage)
  end
end
