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

  def to_imgproxy_url(<<"https://storage.cloud.google.com/", bucket_and_key::binary>>) do
    width = 300
    height = 300
    gravity = "sm"
    enlarge = 0
    source_url = "gs://#{bucket_and_key}"

    "https://images.affable.app/nosignature/fill/#{width}/#{height}/#{gravity}/#{enlarge}/plain/#{
      source_url
    }"
  end

  defp member_of_site?(user, site_id) do
    Repo.exists?(from(SiteMember, where: [user_id: ^user.id, site_id: ^site_id]))
  end
end
