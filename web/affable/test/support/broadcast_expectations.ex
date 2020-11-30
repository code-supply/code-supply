defmodule Affable.BroadcastExpectations do
  import Hammox

  def expect_broadcast(f) do
    expect(Affable.MockBroadcaster, :broadcast, fn payload ->
      f.(payload)
      :ok
    end)
  end

  def expect_broadcast() do
    expect_broadcast(fn _payload -> nil end)
  end

  def stub_broadcast() do
    stub(Affable.MockBroadcaster, :broadcast, fn _payload -> :ok end)
  end
end
