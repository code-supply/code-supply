defmodule Affable.Broadcaster do
  @callback broadcast(%Affable.Messages.WholeSite{
              published: map(),
              preview: map()
            }) :: :ok
end
