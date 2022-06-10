defmodule TlsLbOperator.Runner do
  @spec run({:ok, TlsLbOperator.Processor.operation()}) :: :ok
  def run({:ok, {:replace_certs, names}}) do
    IO.puts("Replacing certs: #{inspect(names)}")
    {:ok, conn} = K8s.Conn.from_service_account()
    ingress = patch_replace(names)
    operation = K8s.Client.patch(ingress)
    {:ok, patched} = K8s.Client.run(conn, operation)
    IO.puts("Success! #{inspect(patched)}")
    :ok
  end

  def run({:ok, operation}) do
    IO.inspect(operation)
    :ok
  end

  defp patch_replace(secret_names) do
    %{
      "apiVersion" => "networking.k8s.io/v1",
      "kind" => "Ingress",
      "metadata" => %{
        "name" => "load-balancer-affable"
      },
      "spec" => %{
        "tls" =>
          for name <- secret_names do
            %{"secretName" => name}
          end
      }
    }
  end

  # defp base_ingress() do
  #   %{
  #     "apiVersion" => "networking.k8s.io/v1",
  #     "kind" => "Ingress",
  #     "metadata" => %{
  #       "annotations" => %{
  #         "kubernetes.io/ingress.class" => "gce",
  #         "kubernetes.io/ingress.allow-http" => "false",
  #         "kubernetes.io/ingress.global-static-ip-name" => "affable"
  #       },
  #       "name" => "load-balancer-affable"
  #     },
  #     "spec" => %{
  #       "tls" => [
  #         %{"secretName" => "affable-www"}
  #       ],
  #       "defaultBackend" => %{
  #         "service" => %{
  #           "name" => "affable",
  #           "port" => %{
  #             "number" => 80
  #           }
  #         }
  #       },
  #       "rules" => [
  #         %{
  #           "host" => "images.affable.app",
  #           "http" => %{
  #             "paths" => [
  #               %{
  #                 "path" => "/*",
  #                 "pathType" => "ImplementationSpecific",
  #                 "backend" => %{
  #                   "service" => %{
  #                     "name" => "imgproxy",
  #                     "port" => %{
  #                       "number" => 80
  #                     }
  #                   }
  #                 }
  #               }
  #             ]
  #           }
  #         }
  #       ]
  #     }
  #   }
  # end
end
