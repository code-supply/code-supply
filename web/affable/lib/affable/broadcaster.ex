defmodule Affable.Broadcaster do
  @callback broadcast(%{
              published: map(),
              preview: map()
            }) :: :ok
end
