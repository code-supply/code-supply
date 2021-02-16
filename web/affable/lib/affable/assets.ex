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
        %Asset{url: "gs://#{bucket_name}/#{key}"},
        params
      )
      |> Repo.insert()
    else
      {:error, Asset.changeset(%Asset{}, params)}
    end
  end

  def to_imgproxy_url(resource, attrs \\ [width: 300, height: 300])

  def to_imgproxy_url(nil, _attrs) do
    nil
  end

  def to_imgproxy_url(%Asset{url: url}, attrs) do
    to_imgproxy_url(url, attrs)
  end

  def to_imgproxy_url(source_url, width: width, height: height) do
    gravity = "sm"
    enlarge = 0

    "https://images.affable.app/nosignature/auto/#{width}/#{height}/#{gravity}/#{enlarge}/plain/#{
      source_url
    }"
  end

  defp member_of_site?(user, site_id) do
    Repo.exists?(from(SiteMember, where: [user_id: ^user.id, site_id: ^site_id]))
  end
end
