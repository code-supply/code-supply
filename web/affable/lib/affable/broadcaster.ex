defmodule Affable.Broadcaster do
  alias Affable.Sites.Site

  @callback broadcast(%Site{}) :: :ok
end
