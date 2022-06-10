defmodule TlsLbOperator.Processor do
  @type operation() ::
          {:replace_certs, list(any())}
          | :nothing_to_do
          | {:add_cert, String.t()}
          | {:remove_cert, String.t()}
          | {:unrecognised_binding_context, String.t()}
  @spec process(list()) :: {:ok, operation()}
  def process([
        %{
          "type" => "Event",
          "watchEvent" => "Added",
          "object" => %{
            "type" => "kubernetes.io/tls",
            "metadata" => %{"name" => name}
          }
        }
      ]) do
    {:ok, {:add_cert, name}}
  end

  def process([
        %{
          "type" => "Event",
          "watchEvent" => "Deleted",
          "object" => %{
            "type" => "kubernetes.io/tls",
            "metadata" => %{"name" => name}
          }
        }
      ]) do
    {:ok, {:remove_cert, name}}
  end

  def process([%{"type" => "Event"}]) do
    {:ok, :nothing_to_do}
  end

  def process([%{"type" => "Synchronization"} | _] = binding_context) do
    {:ok,
     {:replace_certs,
      for binding <- binding_context, reduce: [] do
        acc ->
          acc ++
            (binding["objects"]
             |> Enum.filter(&(&1["object"]["type"] == "kubernetes.io/tls"))
             |> Enum.map(& &1["object"]["metadata"]["name"]))
      end}}
  end

  def process(context) do
    {:ok, {:unrecognised_binding_context, context}}
  end
end
