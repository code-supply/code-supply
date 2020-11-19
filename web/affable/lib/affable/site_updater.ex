defmodule Affable.SiteUpdater do
  @behaviour Affable.Broadcaster
  use GenServer

  alias Phoenix.PubSub

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init({site_io, pubsub, topic}) do
    PubSub.subscribe(pubsub, topic)
    {:ok, %{pubsub: pubsub, site_io: site_io}}
  end

  @impl true
  def broadcast(site) do
    GenServer.cast(__MODULE__, %{
      topic: Affable.ID.site_name_from_id(site["id"]),
      site: site
    })
  end

  @impl true
  def handle_info(site_topic, %{pubsub: pubsub, site_io: site_io} = state) do
    id = Affable.ID.id_from_site_name(site_topic)
    {:ok, _} = site_io.set_available(id, DateTime.utc_now())
    {:ok, raw_site} = site_io.get_raw_site(id)
    PubSub.broadcast(pubsub, site_topic, raw_site)
    {:noreply, state}
  end

  @impl true
  def handle_cast(%{topic: site_topic, site: site}, %{pubsub: pubsub} = state) do
    PubSub.broadcast(pubsub, site_topic, site)
    {:noreply, state}
  end
end
