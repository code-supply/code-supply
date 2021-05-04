defmodule Affable.HTTP do
  @callback head(String.t()) ::
              :ok | {:error, term()}
  @callback put(map(), String.t()) ::
              {:ok, map()} | {:error, %{code: pos_integer(), message: String.t()}}
end
