defmodule Hosting.Assets do
  import Ecto.Query, warn: false
  import Hosting.Sites, only: [site_member?: 2]

  alias Hosting.Accounts.User
  alias Hosting.Assets.Asset
  alias Hosting.Repo

  def default_query do
    from(a in Asset, order_by: [desc: a.updated_at])
  end

  def create_uploaded(kwargs) do
    expected_key = "asset-#{kwargs[:key]}"

    case Ecto.Multi.new()
         |> create_uploaded_multi(kwargs)
         |> Hosting.Repo.transaction() do
      {:ok, %{^expected_key => asset}} ->
        {:ok, asset}

      {:error, ^expected_key, changeset, _others} ->
        {:error, changeset}
    end
  end

  def create_uploaded_multi(
        multi,
        user: user,
        bucket_name: bucket_name,
        key: key,
        params: %{"site_id" => site_id} = params
      ) do
    changeset =
      Asset.changeset(
        %Asset{},
        Map.put(params, "url", "gs://#{bucket_name}/#{key}")
      )

    if site_member?(user, site_id) do
      Ecto.Multi.insert(multi, "asset-#{key}", changeset)
    else
      Ecto.Multi.error(multi, "asset-#{key}", changeset)
    end
  end

  def to_imgproxy_url(resource, attrs \\ [width: 600, height: 600])

  def to_imgproxy_url(nil, _attrs) do
    nil
  end

  def to_imgproxy_url(%Asset{url: url}, attrs) do
    to_imgproxy_url(url, attrs)
  end

  def to_imgproxy_url(source_url,
        width: width,
        height: height
      ) do
    to_imgproxy_url(source_url, width: width, height: height, resizing_type: "fit")
  end

  def to_imgproxy_url(source_url,
        width: width,
        height: height,
        resizing_type: resizing_type
      ) do
    gravity = "ce"
    enlarge = 0

    "https://hosting-images.code.supply/nosignature/#{resizing_type}/#{width}/#{height}/#{gravity}/#{enlarge}/plain/#{source_url}"
  end

  def delete(%User{} = user, asset_id) do
    asset = Repo.get!(Asset, asset_id)

    if user |> site_member?(asset.site_id) do
      Repo.delete(asset)
    else
      {:error, "Not a member of the site"}
    end
  end
end
