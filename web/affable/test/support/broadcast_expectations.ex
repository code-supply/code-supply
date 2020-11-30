defmodule Affable.BroadcastExpectations do
  import Hammox

  alias Affable.Messages.WholeSite

  def expect_broadcast(f) do
    expect(Affable.MockBroadcaster, :broadcast, fn %WholeSite{} = payload ->
      f.(payload)
      :ok
    end)
  end

  def expect_broadcast() do
    expect_broadcast(fn %WholeSite{} -> nil end)
  end

  def stub_broadcast() do
    stub(Affable.MockBroadcaster, :broadcast, fn %WholeSite{} -> :ok end)
  end
end
