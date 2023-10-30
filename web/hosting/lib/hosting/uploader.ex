defmodule Hosting.Uploader do
  alias Phoenix.LiveView.UploadEntry
  alias Hosting.Uploads.UploadRequest
  alias Hosting.Uploads
  alias Hosting.Assets
  alias Hosting.Sites.Site

  defmodule PresignedUpload do
    @derive Jason.Encoder
    defstruct [:uploader, :url, :fields]
  end

  @type record_option ::
          {:site, map()}
          | {:user, map()}
          | {:entry, Phoenix.LiveView.UploadEntry.t()}
          | {:params, map()}
          | {:content, String.t()}
  @spec record(Ecto.Multi.t(), [record_option]) :: Ecto.Multi.t()
  def record(
        multi,
        site: site,
        user: user,
        entry: entry,
        params: params,
        content: content
      ) do
    case entry.client_type do
      "text/html" ->
        record_page(
          multi,
          entry.uuid,
          site,
          entry.client_name,
          strip_root(entry.client_relative_path),
          content
        )

      "text/css" ->
        record_css(multi, site, content)

      _ ->
        record_asset(
          multi,
          user,
          site,
          bucket_name(),
          entry.uuid,
          Map.put(params, "name", entry.client_name)
        )
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
    if Keyword.has_key?(Ecto.Multi.to_list(multi), :update_stylesheet) do
      multi
    else
      Ecto.Multi.update(multi, :update_stylesheet, Site.changeset(site, %{stylesheet: content}))
    end
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
    path = path || Path.join([""])

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

  def presign_upload(uuid) do
    upload_request = %UploadRequest{
      algorithm: "GOOG4-RSA-SHA256",
      access_key_id: access_key_id(),
      bucket_name: bucket_name(),
      key: uuid,
      now: DateTime.now!("Etc/UTC")
    }

    signed_upload = Uploads.sign(upload_request)

    %PresignedUpload{
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
  end

  def presign_upload(%UploadEntry{uuid: uuid}, socket) do
    {:ok, presign_upload(uuid), socket}
  end

  def bucket_name do
    Application.fetch_env!(:hosting, :bucket_name)
  end

  defp access_key_id do
    Application.fetch_env!(:hosting, :access_key_id)
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
