defmodule TlsLbOperator do
  alias TlsLbOperator.Processor
  alias TlsLbOperator.Runner

  @spec main(list(binary())) :: :ok
  def main(["--config"]) do
    %{
      "configVersion" => "v1",
      "kubernetes" => [
        %{
          "name" => "hosting secrets",
          "kind" => "Secret",
          "executeHookOnEvent" => ["Added", "Deleted"],
          "namespace" => %{"nameSelector" => %{"matchNames" => ["hosting"]}},
          "includeSnapshotsFrom" => ["hosting secrets"]
        }
      ]
    }
    |> Jason.encode!()
    |> IO.puts()
  end

  def main(_) do
    System.get_env("BINDING_CONTEXT_PATH")
    |> File.read!()
    |> Jason.decode!()
    |> Processor.process()
    |> Runner.run()
  end
end
