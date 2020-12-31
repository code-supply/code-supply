defmodule Affiliate.RealHTTP do
  @behaviour Affiliate.HTTP

  @impl true
  def get(url) do
    HTTPoison.start()

    case HTTPoison.get!(url) do
      %HTTPoison.Response{body: body, status_code: 200} ->
        {:ok, Jason.decode!(body)}

      %HTTPoison.Response{status_code: code, body: body} ->
        {:error, %{code: code, message: body}}
    end
  end
end
