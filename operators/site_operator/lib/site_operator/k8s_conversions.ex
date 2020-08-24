defmodule SiteOperator.K8sConversions do
  alias SiteOperator.K8s.{
    Certificate,
    Deployment,
    Gateway,
    Namespace,
    Secret,
    Service,
    VirtualService
  }

  @prefix "customer-"
  @affiliate_image_sha "a3fd9bf69c19da78530d74ae179bc29520fcc5e1e91570a66d31d1b9865f9eff"

  def to_k8s(%Certificate{name: name, domains: domains}) do
    %{
      "apiVersion" => "cert-manager.io/v1alpha2",
      "kind" => "Certificate",
      "metadata" => %{
        "name" => name,
        "namespace" => "istio-system"
      },
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

  def to_k8s(%Deployment{name: name}) do
    %{
      "apiVersion" => "apps/v1",
      "kind" => "Deployment",
      "metadata" => standard_metadata(name),
      "spec" => %{
        "selector" => %{
          "matchLabels" => %{
            "app" => "affiliate"
          }
        },
        "template" => %{
          "metadata" => %{
            "labels" => %{
              "app" => "affiliate",
              "version" => "1"
            }
          },
          "spec" => %{
            "containers" => [
              %{
                "name" => "app",
                "image" => "eu.gcr.io/code-supply/affiliate@sha256:#{@affiliate_image_sha}",
                "envFrom" => [%{"secretRef" => %{"name" => "affiliate"}}]
              }
            ]
          }
        }
      }
    }
  end

  def to_k8s(%Secret{name: name, data: data}) do
    %{
      "apiVersion" => "v1",
      "kind" => "Secret",
      "metadata" => standard_metadata(name),
      "type" => "Opaque",
      "data" =>
        for {k, v} <- data, into: %{} do
          {k, Base.encode64(v)}
        end
    }
  end

  def to_k8s(%Service{name: name}) do
    %{
      "apiVersion" => "v1",
      "kind" => "Service",
      "metadata" => standard_metadata(name),
      "spec" => %{
        "selector" => %{
          "app" => "affiliate"
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

  def to_k8s(%VirtualService{name: name, domains: domains}) do
    %{
      "apiVersion" => "networking.istio.io/v1beta1",
      "kind" => "VirtualService",
      "metadata" => standard_metadata(name),
      "spec" => %{
        "gateways" => ["affiliate"],
        "hosts" => domains,
        "http" => [
          %{
            "match" => [%{"uri" => %{"prefix" => "/"}}],
            "route" => [%{"destination" => %{"host" => "affiliate"}}]
          }
        ]
      }
    }
  end

  def from_k8s(%{
        "kind" => "Certificate",
        "metadata" => %{"name" => name},
        "spec" => %{"dnsNames" => domains}
      }) do
    %Certificate{name: unprefixed(name), domains: domains}
  end

  def from_k8s(%{"kind" => "Namespace", "metadata" => %{"name" => name}}) do
    %Namespace{name: unprefixed(name)}
  end

  def from_k8s(%{"kind" => "Deployment", "metadata" => %{"name" => name}}) do
    %Deployment{name: unprefixed(name)}
  end

  def from_k8s(%{"kind" => "Service", "metadata" => %{"name" => name}}) do
    %Service{name: unprefixed(name)}
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
    %{"name" => "affiliate", "namespace" => prefixed(name)}
  end
end
