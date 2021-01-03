defmodule Affable.Assets do
  import Ecto.Query, warn: false

  alias Affable.Repo
  alias Affable.Assets.Asset
  alias Affable.Sites.SiteMember

  def create(user, %{"site_id" => site_id} = params) do
    if Repo.exists?(from(SiteMember, where: [user_id: ^user.id, site_id: ^site_id])) do
      Asset.changeset(%Asset{}, params)
      |> Repo.insert()
    else
      {:error, Asset.changeset(%Asset{}, params)}
    end
  end
end
