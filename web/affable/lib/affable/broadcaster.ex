defmodule Affable.Broadcaster do
  alias Affable.Sites.Payload

  @callback broadcast(%Payload{
              published: map(),
              preview: map()
            }) :: :ok
end
