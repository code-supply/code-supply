defmodule TlsLbOperator.Runner do
  @spec run({:ok, TlsLbOperator.Processor.operation()}) :: :ok
  def run({:ok, operation}) do
    IO.inspect(operation)
    :ok
  end
end
