defmodule Affiliate.SiteState do
  use GenServer

  alias Phoenix.PubSub

  def start_link(subscribe_args) do
    GenServer.start_link(__MODULE__, subscribe_args, name: __MODULE__)
  end

  def init({pubsub, incoming_topic, outgoing_topic}) do
    PubSub.subscribe(pubsub, incoming_topic)
    PubSub.broadcast(pubsub, outgoing_topic, incoming_topic)
    {:ok, %{subscription: {pubsub, incoming_topic}, payload: %{preview: %{}}}}
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def subscription_info() do
    GenServer.call(__MODULE__, :get_subscription_info)
  end

  def handle_call(:get, _from, %{payload: payload} = state) do
    {:reply, payload, state}
  end

  def handle_call(:get_subscription_info, _from, %{subscription: subscription} = state) do
    {:reply, subscription, state}
  end

  def handle_info(payload, state) do
    {:noreply, %{state | payload: payload}}
  end
end
