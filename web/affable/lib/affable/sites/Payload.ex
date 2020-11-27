defmodule Affable.Sites.Payload do
  @enforce_keys [:preview, :published]
  defstruct [:preview, :published]
end
