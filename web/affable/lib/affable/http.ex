defmodule Affable.HTTP do
  @callback put(map(), String.t()) ::
              {:ok, map()} | {:error, %{code: pos_integer(), message: String.t()}}
end
