defmodule Hosting.Storage do
  @callback delete(bucket_name :: String.t(), key :: String.t()) ::
              {:ok, term()} | {:error, term()}
  @callback put(bucket_name :: String.t(), key :: String.t(), content :: String.t()) ::
              {:ok, term} | {:error, String.t()}
  @callback poll(bucket_name :: String.t(), key :: String.t(), delay :: number()) ::
              {:ok, term} | {:error, String.t()}
end
