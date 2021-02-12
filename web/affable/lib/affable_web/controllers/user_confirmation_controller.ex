defmodule AffableWeb.UserConfirmationController do
  use AffableWeb, :controller

  require Logger

  alias Affable.Accounts
  alias Affable.Accounts.User
  alias Affable.Domains.Domain
  alias Affable.K8sFactories
  alias Affable.Sites.Site

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"user" => %{"email" => email}}) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &Routes.user_confirmation_url(conn, :confirm, &1)
      )
    end

    # Regardless of the outcome, show an impartial success/error message.
    conn
    |> put_flash(
      :info,
      "If your e-mail is in our system and it has not been confirmed yet, " <>
        "you will receive an e-mail with instructions shortly."
    )
    |> redirect(to: "/")
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def confirm(conn, %{"token" => token}) do
    case Accounts.confirm_user(token) do
      {:ok,
       %User{
         sites: [
           %Site{
             internal_name: internal_name,
             domains: [%Domain{name: domain_name}]
           }
         ]
       }} ->
        case k8s().deploy(K8sFactories.affiliate_site(internal_name, [domain_name])) do
          {:ok, _} ->
            Logger.info("Deployed site #{internal_name} for the first time")

            conn
            |> put_flash(
              :info,
              "Account confirmed successfully. We're busy building your first site. It should be ready in a few seconds."
            )

          {:error, msg} ->
            Logger.error("Failed to deploy #{internal_name}: #{msg}")

            conn
            |> put_flash(
              :info,
              "Account confirmed successfully. We're busy building your first site. Please get in touch if it's not ready soon!"
            )
        end
        |> redirect(to: Routes.sites_path(conn, :index))

      :error ->
        conn
        |> put_flash(:error, "Confirmation link is invalid or it has expired.")
        |> redirect(to: "/")
    end
  end

  defp k8s() do
    Application.get_env(:affable, :k8s)
  end
end
