defmodule Affable.Broadcaster do
  @callback broadcast(map()) :: :ok
end
