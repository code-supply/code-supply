defmodule SiteOperator.K8s.Conversions do
  alias SiteOperator.Domain

  alias SiteOperator.K8s.{
    AffiliateSite,
    AuthorizationPolicy,
    Certificate,
    Deployment,
    Gateway,
    Ingress,
    Namespace,
    Secret,
    Service,
    VirtualService
  }

  alias SiteOperator.PhoenixSites.PhoenixSite

  def to_k8s(%AuthorizationPolicy{
        name: name,
        namespace: namespace,
        allow_all_with_methods: methods,
        allow_all_from_namespaces: namespaces
      }) do
    %{
      "apiVersion" => "security.istio.io/v1beta1",
      "kind" => "AuthorizationPolicy",
      "metadata" => %{
        "name" => name,
        "namespace" => namespace
      },
      "spec" => %{
        "rules" => [
          %{
            "from" => [
              %{"source" => %{"namespaces" => namespaces}}
            ]
          },
          %{
            "to" => [
              %{"operation" => %{"methods" => methods}}
            ]
          }
        ]
      }
    }
  end

  def to_k8s(%Certificate{name: site_name, domains: domains}) do
    %{
      "apiVersion" => "cert-manager.io/v1",
      "kind" => "Certificate",
      "metadata" => %{
        "name" => site_name,
        "namespace" => "istio-system"
      },
      "spec" => %{
        "secretName" => Certificate.secret_name(site_name),
        "issuerRef" => %{
          "name" => "letsencrypt-production",
          "kind" => "ClusterIssuer"
        },
        "dnsNames" => domains
      }
    }
  end

  # to be used for get/patch only!
  def to_k8s(%Ingress{name: name, tls_secret_names: tls_secret_names}) do
    %{
      "apiVersion" => "networking.k8s.io/v1",
      "kind" => "Ingress",
      "metadata" => %{
        "name" => name,
        "namespace" => "istio-system"
      },
      "spec" => %{
        "tls" =>
          for name <- tls_secret_names do
            %{"secretName" => name}
          end
      }
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
            "annotations" => %{
              "sidecar.istio.io/proxyCPU" => "5m",
              "sidecar.istio.io/proxyCPULimit" => "100m"
            },
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
                  %{"name" => "http", "containerPort" => 4000}
                ],
                "livenessProbe" => %{
                  "tcpSocket" => %{
                    "port" => "http"
                  }
                },
                "readinessProbe" => %{
                  "tcpSocket" => %{
                    "port" => "http"
                  }
                },
                "resources" => %{
                  "limits" => %{
                    "cpu" => "250m",
                    "memory" => "115Mi"
                  },
                  "requests" => %{
                    "cpu" => "3m",
                    "memory" => "50Mi"
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
            "hosts" => namespaced_domains(namespace, domains),
            "port" => %{
              "name" => "http",
              "number" => 80,
              "protocol" => "HTTP"
            }
          },
          %{
            "hosts" => namespaced_domains(namespace, domains),
            "port" => %{
              "name" => "https",
              "number" => 443,
              "protocol" => "HTTPS"
            },
            "tls" => %{
              "credentialName" =>
                if Domain.any_custom?(domains) do
                  Certificate.secret_name(namespace)
                else
                  "affable-www"
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
        domains: domains,
        redirect: redirect
      }) do
    %{
      "apiVersion" => "networking.istio.io/v1beta1",
      "kind" => "VirtualService",
      "metadata" => %{"name" => name, "namespace" => namespace},
      "spec" => %{
        "gateways" => gateways,
        "hosts" => domains,
        "http" => redirect_http_routes(redirect) ++ http_routes(namespace)
      }
    }
  end

  defp redirect_http_routes({from, to}) do
    [
      %{
        "match" => [%{"authority" => %{"prefix" => from}}],
        "redirect" => %{"authority" => to}
      }
    ]
  end

  defp redirect_http_routes(_) do
    []
  end

  defp http_routes(namespace) do
    avoid_letsencrypt_verification = "/[^.]?.*"

    [
      %{
        "match" => [%{"uri" => %{"regex" => avoid_letsencrypt_verification}}],
        "route" => [%{"destination" => %{"host" => "app.#{namespace}.svc.cluster.local"}}]
      }
    ]
  end

  defp namespaced_domains(namespace, domains) do
    for domain <- domains do
      "#{namespace}/#{domain}"
    end
  end

  defp affiliate_site_image do
    Application.get_env(:site_operator, :affiliate_site_image)
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
      live_view_signing_salt: generate_secret_key()
    }
  end

  def from_k8s(%{
        "kind" => "AuthorizationPolicy",
        "metadata" => %{"name" => name, "namespace" => namespace},
        "spec" => %{
          "rules" => [
            %{"from" => [%{"source" => %{"namespaces" => namespaces}}]},
            %{"to" => [%{"operation" => %{"methods" => methods}}]}
          ]
        }
      }) do
    %AuthorizationPolicy{
      name: name,
      namespace: namespace,
      allow_all_from_namespaces: namespaces,
      allow_all_with_methods: methods
    }
  end

  def from_k8s(%{
        "kind" => "Certificate",
        "metadata" => %{"name" => name},
        "spec" => %{"dnsNames" => domains}
      }) do
    %Certificate{name: name, domains: domains}
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
        "kind" => "Ingress",
        "metadata" => %{"name" => name},
        "spec" => %{
          "tls" => entries
        }
      }) do
    %Ingress{
      name: name,
      tls_secret_names: for(%{"secretName" => name} <- entries, do: name)
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
        "spec" => %{"servers" => servers}
      }) do
    [%{"hosts" => ns_prefixed_domains} | _] =
      servers
      |> Enum.reject(&match?(%{"hosts" => ["*"]}, &1))

    %Gateway{
      name: name,
      namespace: namespace,
      domains:
        for d <- ns_prefixed_domains do
          [_ns | [domain | []]] = String.split(d, "/", parts: 2)
          domain
        end
    }
  end

  def from_k8s(%{
        "kind" => "VirtualService",
        "metadata" => %{"name" => name, "namespace" => namespace},
        "spec" => %{
          "gateways" => gateways,
          "hosts" => domains,
          "http" => routes
        }
      }) do
    %VirtualService{
      name: name,
      namespace: namespace,
      gateways: gateways,
      domains: domains,
      redirect:
        case routes do
          [
            %{
              "match" => [%{"authority" => %{"prefix" => from}}],
              "redirect" => %{"authority" => to}
            }
            | _
          ] ->
            {from, to}

          _ ->
            nil
        end
    }
  end
end
