defmodule Hosting.StorageTest do
  defmacro __using__(options) do
    quote do
      use Hosting.DataCase, async: true

      @moduletag unquote(options)

      test "can poll for uploaded content", %{storage: storage} do
        storage.delete("hosting-uploads-dev", "test-fixture")

        delayed_store =
          Task.async(fn ->
            :timer.sleep(100)
            storage.put("hosting-uploads-dev", "test-fixture", "the static test fixture")
          end)

        assert storage.poll("hosting-uploads-dev", "test-fixture") ==
                 {:ok, "the static test fixture"}

        Task.await(delayed_store)
      end

      test "errors when retrieving non-existent content", %{storage: storage} do
        assert storage.poll("hosting-uploads-dev", "not-a-real-key", 0) ==
                 {:error, "No such object: hosting-uploads-dev/not-a-real-key"}
      end
    end
  end
end

defmodule Hosting.GCSStorageTest do
  use Hosting.StorageTest, storage: Hosting.GCSStorage
end

defmodule Hosting.FakeStorageTest do
  use Hosting.StorageTest, storage: Hosting.FakeStorage
end
