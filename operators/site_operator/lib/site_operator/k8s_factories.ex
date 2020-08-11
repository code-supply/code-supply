defmodule SiteOperator.K8sFactories do
  alias SiteOperator.K8s.{
    Certificate,
    Deployment,
    Gateway,
    Namespace,
    Service,
    VirtualService
  }

  def to_k8s(%Certificate{name: name, domains: domains}) do
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
        "dnsNames" => domains
      }
    }
  end

  def to_k8s(%Deployment{name: name}) do
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

  def to_k8s(%Gateway{name: name, domain: domain}) do
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

  def to_k8s(%Service{name: name}) do
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

  def to_k8s(%Namespace{name: name}) do
    %{
      "apiVersion" => "v1",
      "kind" => "Namespace",
      "metadata" => %{
        "name" => prefixed(name),
        "labels" => %{
          "istio-injection" => "enabled"
        }
      }
    }
  end

  def to_k8s(%VirtualService{name: name, domain: domain}) do
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

  def prefixed(name) do
    "customer-#{name}"
  end

  defp certificate_secret_name(name) do
    "tls-#{name}"
  end

  defp standard_metadata(name) do
    %{"name" => name, "namespace" => prefixed(name)}
  end
end
