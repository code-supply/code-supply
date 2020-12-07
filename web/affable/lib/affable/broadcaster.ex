defmodule Affable.Broadcaster do
  alias Affable.Sites.{Item, Site}

  @callback broadcast(%Site{}) :: :ok
  @callback broadcast(append: %Item{}) :: :ok
end
