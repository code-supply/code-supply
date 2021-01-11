defmodule Affable.Uploads do
  @expiration_seconds 1800
  @max_file_size 10_000_000

  alias Affable.Uploads.UploadRequest
  alias Affable.Uploads.SignedUpload

  def sign(%UploadRequest{
        algorithm: algorithm,
        bucket_name: bucket_name,
        key: key,
        access_key_id: access_key_id,
        now: now,
        google_service_account_json: google_service_account_json
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

    client = GcsSignedUrl.Client.load(google_service_account_json)
    signature = GcsSignedUrl.Crypto.sign(policy_json_64, client)

    %SignedUpload{
      key: key,
      policy: policy_json_64,
      algorithm: algorithm,
      credential: "#{access_key_id}/#{credential_scope}",
      date: valid_from.datetime,
      signature: signature |> Base.encode16()
    }
  end

  defp expiration(now) do
    now
    |> DateTime.add(@expiration_seconds, :second)
    |> DateTime.to_iso8601()
  end
end
