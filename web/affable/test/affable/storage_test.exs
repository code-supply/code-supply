defmodule Affable.StorageTest do
  defmacro __using__(options) do
    quote do
      use Affable.DataCase, async: true

      @moduletag unquote(options)

      test "can poll for uploaded content", %{storage: storage} do
        storage.delete("affable-uploads-dev", "test-fixture")

        delayed_store =
          Task.async(fn ->
            :timer.sleep(100)
            storage.put("affable-uploads-dev", "test-fixture", "the static test fixture")
          end)

        assert storage.poll("affable-uploads-dev", "test-fixture") ==
                 {:ok, "the static test fixture"}

        Task.await(delayed_store)
      end

      test "errors when retrieving non-existent content", %{storage: storage} do
        assert storage.poll("affable-uploads-dev", "not-a-real-key", 0) ==
                 {:error, "No such object: affable-uploads-dev/not-a-real-key"}
      end
    end
  end
end

defmodule Affable.GCSStorageTest do
  use Affable.StorageTest, storage: Affable.GCSStorage
end

defmodule Affable.FakeStorageTest do
  use Affable.StorageTest, storage: Affable.FakeStorage
end
