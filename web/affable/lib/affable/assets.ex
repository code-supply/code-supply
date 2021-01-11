defmodule Affable.Assets do
  import Ecto.Query, warn: false

  alias Affable.Repo
  alias Affable.Assets.Asset
  alias Affable.Sites.SiteMember

  def create_uploaded(
        user: user,
        bucket_name: bucket_name,
        key: key,
        params: %{"site_id" => site_id} = params
      ) do
    if member_of_site?(user, site_id) do
      Asset.changeset(
        %Asset{url: "https://storage.cloud.google.com/#{bucket_name}/#{key}"},
        params
      )
      |> Repo.insert()
    else
      {:error, Asset.changeset(%Asset{}, params)}
    end
  end

  defp member_of_site?(user, site_id) do
    Repo.exists?(from(SiteMember, where: [user_id: ^user.id, site_id: ^site_id]))
  end
end
