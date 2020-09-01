defmodule AffableWeb.AffiliateSitesLive do
  use AffableWeb, :live_view

  alias Affable.Accounts
  alias Affable.Accounts.User
  alias Affable.Sites
  alias Affable.Sites.Site

  def mount(%{"id" => id}, %{"user_token" => token}, socket) do
    case Accounts.get_user_by_session_token(token) do
      nil ->
        redirect_to_login(socket)

      %User{} = user ->
        {:ok, retrieve_state(user, socket, id)}
    end
  end

  def mount(_params, _logged_out_session, socket) do
    redirect_to_login(socket)
  end

  def handle_event("save", %{"site" => attrs}, %{assigns: %{site_id: id, user: user}} = socket) do
    site = Sites.get_site!(user, id)

    case Sites.update_site(site, attrs) do
      {:ok, site} ->
        complete_update(socket, site)

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset, saved_state: :error)}
    end
  end

  def handle_event("promote", %{"id" => item_id}, %{assigns: %{site_id: id, user: user}} = socket) do
    site = Sites.get_site!(user, id)

    {:ok, site} = Sites.promote_item(site, item_id)
    complete_update(socket, site)
  end

  def handle_event("demote", %{"id" => item_id}, %{assigns: %{site_id: id, user: user}} = socket) do
    site = Sites.get_site!(user, id)

    {:ok, site} = Sites.demote_item(site, item_id)
    complete_update(socket, site)
  end

  def handle_event("show-saving", _, socket) do
    {:noreply, assign(socket, saved_state: :saving)}
  end

  def handle_info(:clear_save, socket) do
    {:noreply, assign(socket, saved_state: :clear)}
  end

  defp redirect_to_login(socket) do
    {:ok, redirect(socket, to: "/users/log_in")}
  end

  defp retrieve_state(user, socket, id) do
    site = Sites.get_site!(user, id)

    assign(socket,
      user: user,
      site_id: id,
      changeset: Site.changeset(site, %{}),
      saved_state: :neutral
    )
  end

  defp complete_update(socket, site) do
    site
    |> broadcast()
    |> reset_changeset(socket)
  end

  defp broadcast(site) do
    :ok = broadcaster().broadcast(Sites.raw(site))
    site
  end

  defp reset_changeset(site, socket) do
    Process.send_after(self(), :clear_save, 2000)
    {:noreply, assign(socket, changeset: Site.changeset(site, %{}), saved_state: :saved)}
  end

  defp broadcaster() do
    Application.get_env(:affable, :broadcaster)
  end
end
