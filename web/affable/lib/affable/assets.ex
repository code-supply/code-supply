defmodule Affable.Assets do
  import Ecto.Query, warn: false
  import Affable.Sites, only: [member_of_site?: 2]

  alias Affable.Repo
  alias Affable.Accounts.User
  alias Affable.Assets.Asset
  alias Affable.Sites.Site

  def default_query() do
    from(a in Asset, order_by: [desc: a.updated_at])
  end

  def create_uploaded(
        user: user,
        bucket_name: bucket_name,
        key: key,
        params: %{"site_id" => site_id} = params
      ) do
    changeset =
      %Asset{}
      |> Asset.changeset(params |> Map.put("url", "gs://#{bucket_name}/#{key}"))

    if user |> member_of_site?(site_id) do
      Repo.insert(changeset)
    else
      {:error, changeset}
    end
  end

  def to_imgproxy_url(resource, attrs \\ [width: 300, height: 300])

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

    "https://images.affable.app/nosignature/#{resizing_type}/#{width}/#{height}/#{gravity}/#{
      enlarge
    }/plain/#{source_url}"
  end

  def delete(%User{} = user, asset_id) do
    asset = Repo.get!(Asset, asset_id)

    if user |> member_of_site?(asset.site_id) do
      Repo.delete(asset)
    else
      {:error, "Not a member of the site"}
    end
  end

  def in_use?(%Asset{id: id}, %Site{header_image_id: id}), do: true
  def in_use?(%Asset{id: id}, %Site{site_logo_id: id}), do: true

  def in_use?(%Asset{id: id}, %Site{items: items}) do
    Enum.any?(items, &(&1.image_id == id))
  end
end
