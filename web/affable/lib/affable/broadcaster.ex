defmodule Affable.Broadcaster do
  @callback broadcast(preview: map()) :: :ok
end
