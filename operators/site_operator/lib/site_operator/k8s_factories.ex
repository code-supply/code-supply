defmodule SiteOperator.K8sFactories do
  alias SiteOperator.K8s.{
    Certificate,
    Deployment,
    Gateway,
    Namespace,
    Service,
    VirtualService
  }

  @prefix "customer-"

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

  def to_k8s(%Gateway{name: name, domains: domains}) do
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
            "hosts" => domains,
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
            "hosts" => domains,
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

  def to_k8s(%VirtualService{name: name, domains: domains}) do
    %{
      "apiVersion" => "networking.istio.io/v1beta1",
      "kind" => "VirtualService",
      "metadata" => standard_metadata(name),
      "spec" => %{
        "gateways" => [name],
        "hosts" => domains,
        "http" => [
          %{
            "match" => [%{"uri" => %{"prefix" => "/"}}],
            "route" => [%{"destination" => %{"host" => name}}]
          }
        ]
      }
    }
  end

  def from_k8s(%{"kind" => "Deployment", "metadata" => %{"name" => name}}) do
    %Deployment{name: unprefixed(name)}
  end

  def from_k8s(%{"kind" => "Namespace", "metadata" => %{"name" => name}}) do
    %Namespace{name: unprefixed(name)}
  end

  def from_k8s(%{
        "kind" => "Certificate",
        "metadata" => %{"name" => name},
        "spec" => %{"dnsNames" => domains}
      }) do
    %Certificate{name: unprefixed(name), domains: domains}
  end

  def from_k8s(%{
        "kind" => "Gateway",
        "metadata" => %{"name" => name},
        "spec" => %{"servers" => [%{"hosts" => domains} | _]}
      }) do
    %Gateway{name: unprefixed(name), domains: domains}
  end

  def from_k8s(%{
        "kind" => "VirtualService",
        "metadata" => %{"name" => name},
        "spec" => %{"hosts" => domains}
      }) do
    %VirtualService{name: unprefixed(name), domains: domains}
  end

  def from_k8s(%{"kind" => "Service", "metadata" => %{"name" => name}}) do
    %Service{name: unprefixed(name)}
  end

  def prefixed(name) do
    "#{@prefix}#{name}"
  end

  def unprefixed(name) do
    name
    |> String.replace_prefix(@prefix, "")
  end

  defp certificate_secret_name(name) do
    "tls-#{name}"
  end

  defp standard_metadata(name) do
    %{"name" => name, "namespace" => prefixed(name)}
  end
end
