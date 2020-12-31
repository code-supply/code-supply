defmodule Affiliate.SiteState do
  use GenServer

  alias Phoenix.PubSub

  def start_link(subscribe_args) do
    GenServer.start_link(__MODULE__, subscribe_args, name: __MODULE__)
  end

  def init({preview_url, published_url}) do
    {:ok, preview} = http().get(preview_url)
    {:ok, published} = http().get(published_url)

    {:ok,
     %{
       preview_url: preview_url,
       published_url: published_url,
       payload: %{preview: preview, published: published}
     }}
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def store(payload) do
    GenServer.call(__MODULE__, store: payload)
  end

  def handle_call(:get, _from, %{payload: payload} = state) do
    {:reply, payload, state}
  end

  def handle_call([store: %{"preview" => preview, "published" => published}], _from, state) do
    payload = %{preview: preview, published: published}
    PubSub.broadcast(Affiliate.PubSub, "updates", payload)
    {:reply, payload, %{state | payload: payload}}
  end

  defp http() do
    Application.get_env(:affiliate, :http)
  end
end
