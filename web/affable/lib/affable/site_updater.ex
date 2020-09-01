defmodule Affable.SiteUpdater do
  use GenServer

  alias Phoenix.PubSub

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init({retriever, pubsub, topic}) do
    PubSub.subscribe(pubsub, topic)
    {:ok, %{pubsub: pubsub, retriever: retriever}}
  end

  def broadcast(site) do
    GenServer.cast(__MODULE__, %{
      topic: Affable.ID.site_name_from_id(site.id),
      site: site
    })
  end

  def handle_info(site_topic, %{pubsub: pubsub, retriever: retriever} = state) do
    id = Affable.ID.id_from_site_name(site_topic)
    {:ok, site} = retriever.get_raw_site(id)
    PubSub.broadcast(pubsub, site_topic, site)
    {:noreply, state}
  end

  def handle_cast(%{topic: site_topic, site: site}, %{pubsub: pubsub} = state) do
    PubSub.broadcast(pubsub, site_topic, site)
    {:noreply, state}
  end
end
