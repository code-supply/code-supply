defmodule Affable.SiteUpdater do
  @behaviour Affable.Broadcaster
  use GenServer

  alias Phoenix.PubSub
  alias Affable.Sites.{Item, Site}

  import Affable.Sites.Raw

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init({site_io, pubsub, topic}) do
    PubSub.subscribe(pubsub, topic)
    {:ok, %{pubsub: pubsub, site_io: site_io}}
  end

  @impl true
  def broadcast(%Site{} = site) do
    GenServer.cast(__MODULE__, %{
      topic: Affable.ID.site_name_from_id(site.id),
      payload: payload(site)
    })
  end

  @impl true
  def broadcast(append: %Item{} = item) do
    GenServer.cast(__MODULE__, %{
      topic: Affable.ID.site_name_from_id(item.site_id),
      payload: payload(append: item)
    })
  end

  @impl true
  def handle_info(site_topic, %{pubsub: pubsub, site_io: site_io} = state) do
    id = Affable.ID.id_from_site_name(site_topic)
    {:ok, _} = site_io.set_available(id, DateTime.utc_now())
    site = site_io.get_site!(id)

    PubSub.broadcast(pubsub, site_topic, payload(site))

    {:noreply, state}
  end

  @impl true
  def handle_cast(%{topic: site_topic, payload: payload}, %{pubsub: pubsub} = state) do
    PubSub.broadcast(pubsub, site_topic, payload)
    {:noreply, state}
  end

  defp payload(%Site{} = site) do
    %Affable.Messages.WholeSite{
      preview: raw(site),
      published: site.latest_publication.data
    }
    |> Map.from_struct()
  end

  defp payload(append: %Item{} = item) do
    %Affable.Messages.Append{
      append: %{item: raw(item)}
    }
    |> Map.from_struct()
  end
end
