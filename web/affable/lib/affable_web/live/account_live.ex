defmodule AffableWeb.AccountLive do
  use AffableWeb, :live_view

  alias Affable.Accounts
  alias Affable.Accounts.User
  alias Affable.Domains
  alias Affable.Domains.Domain

  def mount(_params, %{"user_token" => token}, socket) do
    case Accounts.get_user_by_session_token(token) do
      nil ->
        redirect_to_login(socket)

      %User{} = user ->
        {:ok, retrieve_state(user, socket)}
    end
  end

  def mount(_params, _logged_out_session, socket) do
    redirect_to_login(socket)
  end

  def handle_event(
        "create-domain",
        %{"domain" => params},
        %{assigns: %{user: user}} = socket
      ) do
    case Domains.create_domain(user, params) do
      {:ok, domain} ->
        {:noreply,
         assign(update(socket, :domains, fn domains -> [domain | domains] end),
           domain_changeset: Domains.change_domain(%Domain{})
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, domain_changeset: changeset)}
    end
  end

  defp redirect_to_login(socket) do
    {:ok, redirect(socket, to: "/users/log_in")}
  end

  defp retrieve_state(user, socket) do
    assign(socket,
      user: user,
      domain_changeset: Domains.change_domain(%Domain{}),
      domains: Domains.list_domains(user)
    )
  end
end
