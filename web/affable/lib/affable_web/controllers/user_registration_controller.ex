defmodule AffableWeb.UserRegistrationController do
  use AffableWeb, :controller

  alias Affable.Accounts
  alias Affable.Accounts.User
  alias Affable.Domains.Domain
  alias Affable.K8sFactories
  alias Affable.Sites.Site
  alias AffableWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok,
       %User{
         sites: [
           %Site{
             internal_name: internal_name,
             domains: [%Domain{name: domain_name}]
           }
         ]
       } = user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :confirm, &1)
          )

        k8s().deploy(K8sFactories.affiliate_site(internal_name, [domain_name]))

        conn
        |> put_flash(:info, "User created successfully.")
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def k8s() do
    Application.get_env(:affable, :k8s)
  end
end
