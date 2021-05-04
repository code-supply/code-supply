defmodule Affable.RealHTTP do
  @behaviour Affable.HTTP

  @impl true
  def head(url) do
    HTTPoison.start()

    case HTTPoison.head(url) do
      {:ok, %HTTPoison.Response{headers: headers, status_code: code}} when code in 200..299 ->
        :ok

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @impl true
  def put(obj, url) do
    HTTPoison.start()

    case HTTPoison.put!(url, Jason.encode!(obj), [{"Content-Type", "application/json"}]) do
      %HTTPoison.Response{body: body, status_code: 200} ->
        {:ok, Jason.decode!(body)}

      %HTTPoison.Response{status_code: code, body: body} ->
        {:error, %{code: code, message: body}}
    end
  end
end
