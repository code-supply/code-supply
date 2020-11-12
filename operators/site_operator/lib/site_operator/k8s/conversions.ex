defmodule SiteOperator.K8s.Conversions do
  alias SiteOperator.K8s.{
    AffiliateSite,
    Certificate,
    Deployment,
    Gateway,
    Namespace,
    RoleBinding,
    Secret,
    Service,
    VirtualService
  }

  alias SiteOperator.PhoenixSites.PhoenixSite

  def to_k8s(%Certificate{name: site_name, domains: domains}) do
    %{
      "apiVersion" => "cert-manager.io/v1alpha2",
      "kind" => "Certificate",
      "metadata" => %{
        "name" => site_name,
        "namespace" => "istio-system"
      },
      "spec" => %{
        "secretName" => certificate_secret_name(site_name),
        "issuerRef" => %{
          "name" => "letsencrypt-production",
          "kind" => "ClusterIssuer"
        },
        "dnsNames" => domains
      }
    }
  end

  def to_k8s(%RoleBinding{
        name: name,
        namespace: namespace,
        role_kind: role_kind,
        role_name: role_name,
        subjects: subjects
      }) do
    %{
      "apiVersion" => "rbac.authorization.k8s.io/v1",
      "kind" => "RoleBinding",
      "metadata" => %{"name" => name, "namespace" => namespace},
      "roleRef" => %{
        "apiGroup" => "rbac.authorization.k8s.io",
        "kind" => role_kind,
        "name" => role_name
      },
      "subjects" =>
        for subject <- subjects do
          for {k, v} <- subject, into: %{} do
            {Atom.to_string(k), v}
          end
        end
    }
  end

  def to_k8s(%Namespace{name: name}) do
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

  def to_k8s(%Deployment{name: name, image: image, namespace: namespace, env_vars: env_vars}) do
    %{
      "apiVersion" => "apps/v1",
      "kind" => "Deployment",
      "metadata" => %{"name" => name, "namespace" => namespace},
      "spec" => %{
        "selector" => %{
          "matchLabels" => %{
            "app" => name
          }
        },
        "template" => %{
          "metadata" => %{
            "labels" => %{
              "app" => name,
              "version" => "1"
            }
          },
          "spec" => %{
            "containers" => [
              %{
                "name" => "app",
                "image" => image,
                "ports" => [
                  %{"name" => "http", "containerPort" => 4000},
                  %{"name" => "erlang", "containerPort" => 5555},
                  %{"name" => "epmd", "containerPort" => 4369}
                ],
                "livenessProbe" => %{
                  "httpGet" => %{
                    "path" => "/",
                    "port" => "http"
                  }
                },
                "envFrom" => [%{"secretRef" => %{"name" => name}}],
                "env" =>
                  [
                    %{
                      "name" => "POD_IP",
                      "valueFrom" => %{
                        "fieldRef" => %{"fieldPath" => "status.podIP"}
                      }
                    }
                  ] ++
                    for {k, v} <- env_vars do
                      %{"name" => k, "value" => v}
                    end
              }
            ]
          }
        }
      }
    }
  end

  def to_k8s(%Secret{name: name, namespace: namespace, data: data}) do
    %{
      "apiVersion" => "v1",
      "kind" => "Secret",
      "metadata" => %{"name" => name, "namespace" => namespace},
      "type" => "Opaque",
      "data" =>
        for {k, v} <- data, into: %{} do
          {k, Base.encode64(v)}
        end
    }
  end

  def to_k8s(%Service{name: name, namespace: namespace}) do
    %{
      "apiVersion" => "v1",
      "kind" => "Service",
      "metadata" => %{"name" => name, "namespace" => namespace},
      "spec" => %{
        "selector" => %{
          "app" => name
        },
        "ports" => [
          %{
            "name" => "http",
            "port" => 80,
            "targetPort" => 4000
          }
        ]
      }
    }
  end

  def to_k8s(%Gateway{name: name, namespace: namespace, domains: domains}) do
    %{
      "apiVersion" => "networking.istio.io/v1beta1",
      "kind" => "Gateway",
      "metadata" => %{"name" => name, "namespace" => namespace},
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
              "credentialName" =>
                if domains |> include_custom_domain? do
                  "affable-www"
                else
                  certificate_secret_name(namespace)
                end,
              "mode" => "SIMPLE"
            }
          }
        ]
      }
    }
  end

  def to_k8s(%VirtualService{
        name: name,
        namespace: namespace,
        gateways: gateways,
        domains: domains
      }) do
    %{
      "apiVersion" => "networking.istio.io/v1beta1",
      "kind" => "VirtualService",
      "metadata" => %{"name" => name, "namespace" => namespace},
      "spec" => %{
        "gateways" => gateways,
        "hosts" => domains,
        "http" => [
          %{
            "match" => [%{"uri" => %{"prefix" => "/"}}],
            "route" => [%{"destination" => %{"host" => "affiliate.#{name}.svc.cluster.local"}}]
          }
        ]
      }
    }
  end

  defp affiliate_site_image do
    Application.get_env(:site_operator, :affiliate_site_image)
  end

  defp distribution_cookie do
    Application.get_env(:site_operator, :distribution_cookie)
  end

  defp generate_secret_key do
    case Application.get_env(:site_operator, :secret_key_generator) do
      :generate ->
        length = 64
        :crypto.strong_rand_bytes(length) |> Base.encode64() |> binary_part(0, length)

      value ->
        value
    end
  end

  def from_k8s(%AffiliateSite{} = site) do
    %PhoenixSite{
      name: site.name,
      domains: site.domains,
      image: affiliate_site_image(),
      secret_key_base: generate_secret_key(),
      distribution_cookie: distribution_cookie()
    }
  end

  def from_k8s(%{
        "kind" => "Certificate",
        "metadata" => %{"name" => name},
        "spec" => %{"dnsNames" => domains}
      }) do
    %Certificate{name: name, domains: domains}
  end

  def from_k8s(%{
        "kind" => "RoleBinding",
        "metadata" => %{"name" => name, "namespace" => namespace},
        "roleRef" => %{
          "apiGroup" => "rbac.authorization.k8s.io",
          "kind" => role_kind,
          "name" => role_name
        },
        "subjects" => subjects
      }) do
    %RoleBinding{
      name: name,
      namespace: namespace,
      role_kind: role_kind,
      role_name: role_name,
      subjects:
        for subject <- subjects do
          for {k, v} <- subject, into: %{} do
            {String.to_atom(k), v}
          end
        end
    }
  end

  def from_k8s(%{"kind" => "Namespace", "metadata" => %{"name" => name}}) do
    %Namespace{name: name}
  end

  def from_k8s(%{
        "kind" => "Deployment",
        "metadata" => %{"name" => name, "namespace" => namespace},
        "spec" => %{
          "template" => %{
            "spec" => %{"containers" => [%{"image" => image, "env" => k8s_env_vars}]}
          }
        }
      }) do
    %Deployment{
      name: name,
      image: image,
      namespace: namespace,
      env_vars:
        for %{"name" => k, "value" => v} <- k8s_env_vars, into: %{} do
          {k, v}
        end
    }
  end

  def from_k8s(%{
        "kind" => "Deployment",
        "metadata" => %{"name" => name, "namespace" => namespace},
        "spec" => %{
          "template" => %{
            "spec" => %{"containers" => [%{"image" => image}]}
          }
        }
      }) do
    %Deployment{
      name: name,
      image: image,
      namespace: namespace,
      env_vars: %{}
    }
  end

  def from_k8s(%{
        "kind" => "Secret",
        "metadata" => %{"name" => name, "namespace" => namespace},
        "data" => data
      }) do
    %Secret{
      name: name,
      namespace: namespace,
      data:
        for {k, v} <- data, into: %{} do
          {k, Base.decode64!(v)}
        end
    }
  end

  def from_k8s(%{"kind" => "Service", "metadata" => %{"name" => name, "namespace" => namespace}}) do
    %Service{name: name, namespace: namespace}
  end

  def from_k8s(%{
        "kind" => "Gateway",
        "metadata" => %{"name" => name, "namespace" => namespace},
        "spec" => %{"servers" => [%{"hosts" => domains} | _]}
      }) do
    %Gateway{name: name, namespace: namespace, domains: domains}
  end

  def from_k8s(%{
        "kind" => "VirtualService",
        "metadata" => %{"name" => name, "namespace" => namespace},
        "spec" => %{"gateways" => gateways, "hosts" => domains}
      }) do
    %VirtualService{name: name, namespace: namespace, gateways: gateways, domains: domains}
  end

  defp include_custom_domain?(domains) do
    domains
    |> Enum.all?(&String.ends_with?(&1, ".affable.app"))
  end

  defp certificate_secret_name(name) do
    "tls-#{name}"
  end
end
