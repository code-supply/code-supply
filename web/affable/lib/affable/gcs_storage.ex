defmodule Affable.GCSStorage do
  @behaviour Affable.Storage

  alias GoogleApi.Storage.V1.Api.Objects

  @impl true
  def delete(bucket_name, key) do
    with {:ok, %{token: token}} <- Goth.fetch(Affable.Goth),
         client <- client(token),
         {result, env} <- Objects.storage_objects_delete(client, bucket_name, key) do
      {result, env.body}
    end
  end

  @impl true
  def put(bucket_name, key, content) do
    with {:ok, %{token: token}} <- Goth.fetch(Affable.Goth),
         client <- client(token),
         {result, metadata} <-
           Objects.storage_objects_insert_iodata(
             client,
             bucket_name,
             "multipart",
             %GoogleApi.Storage.V1.Model.Object{name: key},
             content
           ) do
      {result, metadata}
    end
  end

  @impl true
  def poll(bucket_name, key, delay \\ 50) do
    with {:ok, %{token: token}} <- Goth.fetch(Affable.Goth),
         client <- client(token) do
      Enum.reduce_while(1..5, nil, fn n, _acc ->
        case get(client, bucket_name, key) do
          {:ok, env} ->
            {:halt, {:ok, env.body}}

          {:error, env} ->
            :timer.sleep(delay * n)
            {:cont, {:error, env.body}}
        end
      end)
    end
  end

  defp get(client, bucket_name, key) do
    Objects.storage_objects_get(client, bucket_name, key, alt: "media")
  end

  defp client(token) do
    Tesla.client(
      [{Tesla.Middleware.Headers, [{"authorization", "Bearer #{token}"}]}],
      Tesla.Adapter.Hackney
    )
  end
end
