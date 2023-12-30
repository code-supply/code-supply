defmodule Hosting.Uploads do
  @expiration_seconds 1800
  @max_file_size 10_000_000

  alias Hosting.Uploads.SignedUpload
  alias Hosting.Uploads.UploadRequest

  def sign(%UploadRequest{
        algorithm: algorithm,
        bucket_name: bucket_name,
        key: key,
        access_key_id: access_key_id,
        now: now
      }) do
    valid_from = now |> GcsSignedUrl.ISODateTime.generate()
    credential_scope = "#{valid_from.date}/auto/storage/goog4_request"

    policy_json_64 =
      %{
        expiration: expiration(now),
        conditions: [
          %{bucket: bucket_name},
          ["content-length-range", 0, @max_file_size],
          %{key: key},
          %{"x-goog-algorithm": algorithm},
          %{"x-goog-credential": "#{access_key_id}/#{credential_scope}"},
          %{"x-goog-date": valid_from.datetime}
        ]
      }
      |> Jason.encode!()
      |> Base.encode64()

    with {:ok, %{token: token}} <- Goth.fetch(Hosting.Goth),
         oauth_config <- %GcsSignedUrl.SignBlob.OAuthConfig{
           service_account: access_key_id,
           access_token: token
         },
         {:ok, signature_64} <- GcsSignedUrl.Crypto.sign(policy_json_64, oauth_config),
         {:ok, signature} <- Base.decode64(signature_64) do
      %SignedUpload{
        key: key,
        policy: policy_json_64,
        algorithm: algorithm,
        credential: "#{access_key_id}/#{credential_scope}",
        date: valid_from.datetime,
        signature: signature |> Base.encode16()
      }
    end
  end

  defp expiration(now) do
    now
    |> DateTime.add(@expiration_seconds, :second)
    |> DateTime.to_iso8601()
  end
end
