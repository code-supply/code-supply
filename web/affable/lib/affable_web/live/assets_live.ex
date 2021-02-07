defmodule AffableWeb.AssetsLive do
  use AffableWeb, :live_view

  alias Affable.{Accounts, Assets}
  alias Affable.Assets.Asset
  alias Affable.Uploads
  alias Affable.Uploads.UploadRequest
  alias Phoenix.LiveView.UploadEntry

  import Affable.Assets, only: [to_imgproxy_url: 1]

  @impl true
  def mount(_params, %{"user_token" => token}, socket) do
    user =
      Accounts.get_user_by_session_token(token)
      |> Accounts.preload_for_assets()

    if connected?(socket) do
    end

    {
      :ok,
      assign_vars(socket, user)
      |> allow_upload(
        :asset,
        progress: &handle_progress/3,
        external: &presign_upload/2,
        accept: ~w(.png .jpeg .jpg),
        max_entries: 1
      )
    }
  end

  @impl true
  def handle_event("validate", %{"asset" => params}, socket) do
    changeset =
      Asset.changeset(%Asset{}, params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("save", %{"asset" => params}, %{assigns: %{user: user}} = socket) do
    uuid =
      case consume_uploaded_entries(socket, :asset, fn _, %UploadEntry{uuid: uuid} -> uuid end) do
        [uuid] -> uuid
        [] -> nil
      end

    case Assets.create_uploaded(
           user: user,
           bucket_name: bucket_name(),
           key: uuid,
           params: %{"site_id" => site_id} = params
         ) do
      {:ok, new_asset} ->
        {
          :noreply,
          assign_vars(socket, %{
            user
            | sites:
                for site <- user.sites do
                  if "#{site.id}" == site_id do
                    %{site | assets: [new_asset | site.assets]}
                  else
                    site
                  end
                end
          })
        }

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :asset, ref)}
  end

  defp presign_upload(%UploadEntry{uuid: uuid}, socket) do
    upload_request = %UploadRequest{
      algorithm: "GOOG4-RSA-SHA256",
      access_key_id: access_key_id(),
      bucket_name: bucket_name(),
      key: uuid,
      google_service_account_json: google_service_account_json(),
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

  defp assign_vars(socket, user) do
    socket
    |> assign(
      user: user,
      changeset: Asset.changeset(%Asset{}, %{}),
      sites: user.sites
    )
  end

  defp handle_progress(:asset, entry, socket) do
    if entry.done? do
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  defp access_key_id do
    Application.fetch_env!(:affable, :access_key_id)
  end

  defp bucket_name do
    Application.fetch_env!(:affable, :bucket_name)
  end

  defp google_service_account_json do
    Application.fetch_env!(:affable, :google_service_account_json)
    |> Jason.decode!()
  end
end
