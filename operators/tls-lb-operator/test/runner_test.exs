defmodule RunnerTest do
  use ExUnit.Case

  import TlsLbOperator.Runner
  import ExUnit.CaptureIO

  test "when running an unrecognised binding context, outputs the context" do
    assert capture_io(fn -> run({:ok, [%{"foo" => "bar"}]}) end) == "[{\"foo\":\"bar\"}]\n"
  end
end
