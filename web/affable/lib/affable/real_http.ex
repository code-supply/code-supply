defmodule Affable.RealHTTP do
  @behaviour Affable.HTTP

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
