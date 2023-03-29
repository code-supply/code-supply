defmodule AffableWeb.AssetsLive do
  use AffableWeb, :old_live_view

  alias Affable.{Accounts, Assets}
  alias Affable.Assets.Asset
  alias Affable.Sites

  import Affable.Assets, only: [to_imgproxy_url: 2]

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    user =
      Accounts.get_user_by_session_token(token)
      |> Accounts.preload_for_assets()

    {
      :ok,
      assign_vars(socket, user)
    }
  end

  @impl true
  def handle_event("delete-asset", %{"id" => id}, %{assigns: %{user: user}} = socket) do
    {:ok, _} = Assets.delete(user, id)

    {:noreply,
     assign_vars(socket, %{
       user
       | sites:
           for site <- user.sites do
             Sites.reload_assets(site)
           end
     })}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :asset, ref)}
  end

  defp assign_vars(socket, user) do
    socket
    |> assign(
      user: user,
      changeset: Asset.changeset(%Asset{}, %{}),
      sites: user.sites
    )
  end
end
