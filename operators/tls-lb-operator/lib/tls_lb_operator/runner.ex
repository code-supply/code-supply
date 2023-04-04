defmodule TlsLbOperator.Runner do
  @spec run({:ok, TlsLbOperator.Processor.operation()}) :: :ok
  def run({:ok, {:replace_certs, names}}) do
    {:ok, conn} = K8s.Conn.from_service_account()
    ingress = ingress(names)
    operation = K8s.Client.apply(ingress)
    {:ok, _} = K8s.Client.run(conn, operation)
    IO.puts("Successfully replaced certs in LB: #{inspect(names)}")
  end

  def run({:ok, operation}) do
    IO.puts(Jason.encode!(operation))
    :ok
  end

  defp ingress(secret_names) do
    %{
      "apiVersion" => "networking.k8s.io/v1",
      "kind" => "Ingress",
      "metadata" => %{
        "name" => "load-balancer-hosting",
        "namespace" => "hosting"
      },
      "spec" => %{
        "tls" =>
          for name <- secret_names do
            %{"secretName" => name}
          end,
        "rules" => [
          %{
            "http" => %{
              "paths" => [
                %{
                  "path" => "/",
                  "pathType" => "Prefix",
                  "backend" => %{
                    "service" => %{
                      "name" => "hosting",
                      "port" => %{
                        "number" => 80
                      }
                    }
                  }
                }
              ]
            }
          },
          %{
            "host" => "hosting-images.code.supply",
            "http" => %{
              "paths" => [
                %{
                  "path" => "/",
                  "pathType" => "Prefix",
                  "backend" => %{
                    "service" => %{
                      "name" => "imgproxy",
                      "port" => %{
                        "number" => 80
                      }
                    }
                  }
                }
              ]
            }
          }
        ]
      }
    }
  end
end
