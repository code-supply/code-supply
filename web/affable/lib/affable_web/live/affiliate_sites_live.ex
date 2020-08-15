defmodule AffableWeb.AffiliateSitesLive do
  use AffableWeb, :live_view

  alias Affable.Accounts
  alias Affable.Accounts.User
  alias Affable.Sites

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

  # def handle_event(
  #       "create-domain",
  #       %{"domain" => params},
  #       %{assigns: %{user: user}} = socket
  #     ) do
  #   case Domains.create_domain(user, params) do
  #     {:ok, domain} ->
  #       {:noreply,
  #        assign(update(socket, :domains, fn domains -> [domain | domains] end),
  #          domain_changeset: Domains.change_domain(%Domain{})
  #        )}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, domain_changeset: changeset)}
  #   end
  # end

  # def handle_event(
  #       "deploy",
  #       %{"domain_id" => domain_id},
  #       %{assigns: %{user: user}} = socket
  #     ) do
  #   {:ok, _} = Domains.deploy(user, domain_id, k8s())
  #   {:noreply, retrieve_state(user, socket)}
  # end

  # def handle_event(
  #       "undeploy",
  #       %{"domain_id" => domain_id},
  #       %{assigns: %{user: user}} = socket
  #     ) do
  #   {:ok, _} = Domains.undeploy(user, domain_id, k8s())
  #   {:noreply, retrieve_state(user, socket)}
  # end

  defp redirect_to_login(socket) do
    {:ok, redirect(socket, to: "/users/log_in")}
  end

  defp retrieve_state(user, socket, id) do
    assign(socket,
      user: user,
      site: Sites.get_site!(user, id)
    )
  end

  # defp k8s() do
  #   Application.get_env(:affable, :k8s)
  # end
end
