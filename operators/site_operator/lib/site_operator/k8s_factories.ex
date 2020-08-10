defmodule SiteOperator.K8sFactories do
  def service(name) do
    %{
      "apiVersion" => "v1",
      "kind" => "Service",
      "metadata" => standard_metadata(name),
      "spec" => %{
        "selector" => %{
          "so-app" => name
        },
        "ports" => [
          %{
            "name" => "http",
            "port" => 80
          }
        ]
      }
    }
  end

  def deployment(name) do
    %{
      "apiVersion" => "apps/v1",
      "kind" => "Deployment",
      "metadata" => standard_metadata(name),
      "spec" => %{
        "selector" => %{
          "matchLabels" => %{
            "so-app" => name
          }
        },
        "template" => %{
          "metadata" => %{
            "labels" => %{
              "so-app" => name
            }
          },
          "spec" => %{
            "containers" => [
              %{
                "name" => "app",
                "image" => "nginx"
              }
            ]
          }
        }
      }
    }
  end

  def virtual_service(name, domain) do
    %{
      "apiVersion" => "networking.istio.io/v1beta1",
      "kind" => "VirtualService",
      "metadata" => standard_metadata(name),
      "spec" => %{
        "gateways" => [name],
        "hosts" => [domain],
        "http" => [
          %{
            "match" => [%{"uri" => %{"prefix" => "/"}}],
            "route" => [%{"destination" => %{"host" => name}}]
          }
        ]
      }
    }
  end

  def gateway(name, domain) do
    %{
      "apiVersion" => "networking.istio.io/v1beta1",
      "kind" => "Gateway",
      "metadata" => standard_metadata(name),
      "spec" => %{
        "selector" => %{
          "istio" => "ingressgateway"
        },
        "servers" => [
          %{
            "hosts" => [
              domain
            ],
            "port" => %{
              "name" => "http",
              "number" => 80,
              "protocol" => "HTTP"
            },
            "tls" => %{
              "httpsRedirect" => true
            }
          },
          %{
            "hosts" => [
              domain
            ],
            "port" => %{
              "name" => "https",
              "number" => 443,
              "protocol" => "HTTPS"
            },
            "tls" => %{
              "credentialName" => certificate_secret_name(name),
              "mode" => "SIMPLE"
            }
          }
        ]
      }
    }
  end

  def certificate(name, domain) do
    %{
      "apiVersion" => "cert-manager.io/v1alpha2",
      "kind" => "Certificate",
      "metadata" => standard_metadata(name) |> Map.put("namespace", "istio-system"),
      "spec" => %{
        "secretName" => certificate_secret_name(name),
        "issuerRef" => %{
          "name" => "letsencrypt-production",
          "kind" => "ClusterIssuer"
        },
        "dnsNames" => [domain]
      }
    }
  end

  def ns(name) do
    %{
      "apiVersion" => "v1",
      "kind" => "Namespace",
      "metadata" => %{
        "name" => name,
        "labels" => %{
          "istio-injection" => "enabled"
        }
      }
    }
  end

  defp certificate_secret_name(name) do
    "tls-#{name}"
  end

  defp standard_metadata(name) do
    %{"name" => name, "namespace" => name}
  end
end
