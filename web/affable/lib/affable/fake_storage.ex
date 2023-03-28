defmodule Affable.FakeStorage do
  @behaviour Affable.Storage

  @impl true
  def delete(_bucket_name, _key) do
    {:ok, ""}
  end

  @impl true
  def put(_bucket_name, _key, _content) do
    {:ok, ""}
  end

  @impl true
  def poll(bucket_name, key, delay \\ 50)

  @impl true
  def poll(bucket_name, "not-a-real-key" = key, _delay) do
    {:error, "No such object: #{bucket_name}/#{key}"}
  end

  @impl true
  def poll(_bucket_name, _key, _delay) do
    {:ok, "the static test fixture"}
  end
end
