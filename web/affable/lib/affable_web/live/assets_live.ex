defmodule AffableWeb.AssetsLive do
  use AffableWeb, :live_view

  alias Affable.{Accounts, Assets}
  alias Affable.Assets.Asset

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    user =
      Accounts.get_user_by_session_token(token)
      |> Affable.Repo.preload(:sites)

    if connected?(socket) do
    end

    {:ok,
     socket
     |> assign(
       user: user,
       changeset: Asset.changeset(%Asset{}, %{}),
       sites: user.sites
     )
     |> allow_upload(
       :asset,
       progress: &handle_progress/3,
       accept: ~w(.png .jpeg .jpg),
       max_entries: 1
     )}
  end

  @impl true
  def handle_event("validate", %{"asset" => params}, socket) do
    changeset =
      Asset.changeset(%Asset{}, params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"asset" => params}, %{assigns: %{user: user}} = socket) do
    case Assets.create(user, params) do
      {:ok, asset} ->
        uploaded_files =
          consume_uploaded_entries(socket, :asset, fn %{path: path}, _entry ->
            IO.inspect(path)
          end)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :asset, ref)}
  end

  defp handle_progress(:asset, entry, socket) do
    if entry.done? do
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end
end
