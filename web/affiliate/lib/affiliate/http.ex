defmodule Affiliate.HTTP do
  @callback get(String.t()) ::
              {:ok, map()} | {:error, %{code: pos_integer(), message: String.t()}}
end
