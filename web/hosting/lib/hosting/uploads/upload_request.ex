defmodule Hosting.Uploads.UploadRequest do
  @enforce_keys [
    :algorithm,
    :bucket_name,
    :key,
    :access_key_id,
    :now
  ]
  defstruct @enforce_keys
end
