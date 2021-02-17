defmodule Affable.Assets do
  import Ecto.Query, warn: false
  import Affable.Sites, only: [member_of_site?: 2]

  alias Affable.Repo
  alias Affable.Accounts.User
  alias Affable.Assets.Asset

  def default_query() do
    from(a in Asset, order_by: [desc: a.updated_at])
  end

  def create_uploaded(
        user: user,
        bucket_name: bucket_name,
        key: key,
        params: %{"site_id" => site_id} = params
      ) do
    if user |> member_of_site?(site_id) do
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

  def delete(%User{} = user, asset_id) do
    asset = Repo.get!(Asset, asset_id)

    if user |> member_of_site?(asset.site_id) do
      Repo.delete(asset)
    else
      {:error, "Not a member of the site"}
    end
  end
end
