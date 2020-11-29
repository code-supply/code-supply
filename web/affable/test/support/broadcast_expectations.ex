defmodule Affable.BroadcastExpectations do
  import Hammox

  def expect_broadcast(f) do
    expect(Affable.MockBroadcaster, :broadcast, fn %Affable.Sites.Payload{} = payload ->
      f.(payload)
      :ok
    end)
  end

  def expect_broadcast() do
    expect_broadcast(fn %Affable.Sites.Payload{} -> nil end)
  end

  def stub_broadcast() do
    stub(Affable.MockBroadcaster, :broadcast, fn %Affable.Sites.Payload{} -> :ok end)
  end
end
