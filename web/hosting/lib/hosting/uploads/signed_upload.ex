defmodule Hosting.Uploads.SignedUpload do
  @enforce_keys [:key, :policy, :algorithm, :credential, :date, :signature]
  defstruct @enforce_keys
end
