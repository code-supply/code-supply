defmodule Affiliate.SiteState do
  use GenServer

  alias Phoenix.PubSub

  def start_link(subscribe_args) do
    GenServer.start_link(__MODULE__, subscribe_args, name: __MODULE__)
  end

  def init({pubsub, incoming_topic, outgoing_topic}) do
    PubSub.subscribe(pubsub, incoming_topic)
    PubSub.broadcast(pubsub, outgoing_topic, incoming_topic)
    {:ok, %{}}
  end

  def handle_call(:get, _from, existing_site) do
    {:reply, existing_site, existing_site}
  end

  def handle_info(updated_site, _existing_site) do
    {:noreply, updated_site}
  end
end
