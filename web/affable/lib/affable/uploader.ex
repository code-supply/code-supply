defmodule Affable.Uploader do
  alias Phoenix.LiveView.UploadEntry
  alias Affable.Uploads.UploadRequest
  alias Affable.Uploads
  alias Affable.Assets
  alias Affable.Sites.Site

  @type record_option ::
          {:site, map()}
          | {:user, map()}
          | {:key, String.t()}
          | {:params, map()}
          | {:type, String.t()}
          | {:last_modified, String.t()}
  @spec record(Ecto.Multi.t(), [record_option]) :: Ecto.Multi.t()
  def record(
        multi,
        site: site,
        user: user,
        key: key,
        params: params,
        type: type,
        last_modified: _last_modified
      ) do
    case type do
      "text/html" ->
        record_page(multi, key, site, params["name"], params["name"], params["content"])

      "text/css" ->
        record_css(multi, site, params["content"])

      _ ->
        record_asset(multi, user, site, bucket_name(), key, params)
    end
  end

  defp record_page(multi, key, site, title, "/" <> path, content) do
    Ecto.Multi.insert(
      multi,
      "record_page_#{key}",
      site
      |> Ecto.build_assoc(:pages, %{title: title, path: "/" <> path, raw: content})
    )
  end

  defp record_page(multi, key, site, title, path, content) do
    record_page(multi, key, site, title, "/" <> path, content)
  end

  defp record_css(multi, site, content) do
    Ecto.Multi.update(multi, site, Site.changeset(site, %{stylesheet: content}))
  end

  defp record_asset(multi, user, site, bucket_name, key, params) do
    Assets.create_uploaded_multi(
      multi,
      user: user,
      bucket_name: bucket_name,
      key: key,
      params: Map.put(params, "site_id", site.id)
    )
  end

  def strip_root(path) do
    case Path.dirname(path) do
      "." ->
        path

      _ ->
        path
        |> Path.split()
        |> Enum.drop(1)
        |> Path.join()
    end
  end

  def group_directory_entries(entries) do
    for {human_type, entries} <- Enum.group_by(entries, &format_type(&1.client_type)),
        into: [] do
      {human_type, entries}
    end
    |> Enum.sort_by(fn {human_type, _entries} -> human_type == "HTML" || human_type end)
  end

  def presign_upload(%UploadEntry{uuid: uuid}, socket) do
    upload_request = %UploadRequest{
      algorithm: "GOOG4-RSA-SHA256",
      access_key_id: access_key_id(),
      bucket_name: bucket_name(),
      key: uuid,
      now: DateTime.now!("Etc/UTC")
    }

    signed_upload = Uploads.sign(upload_request)

    meta = %{
      uploader: "GCS",
      url: "https://#{bucket_name()}.storage.googleapis.com/",
      fields: %{
        key: uuid,
        policy: signed_upload.policy,
        "x-goog-algorithm": signed_upload.algorithm,
        "x-goog-credential": signed_upload.credential,
        "x-goog-date": signed_upload.date,
        "x-goog-signature": signed_upload.signature
      }
    }

    {:ok, meta, socket}
  end

  def bucket_name do
    Application.fetch_env!(:affable, :bucket_name)
  end

  defp access_key_id do
    Application.fetch_env!(:affable, :access_key_id)
  end

  defp format_type("text/" <> rest) do
    String.upcase(rest)
  end

  defp format_type("image/" <> _rest) do
    "Images"
  end

  defp format_type(_) do
    "Other"
  end
end