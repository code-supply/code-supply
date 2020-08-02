defmodule SiteOperator.K8sFactories do
  def service(name) do
    %{
      "apiVersion" => "v1",
      "kind" => "Service",
      "metadata" => %{
        "name" => name,
        "namespace" => name
      },
      "spec" => %{
        "selector" => %{
          "so-app" => name
        },
        "ports" => [%{"name" => "http", "port" => 80}]
      }
    }
  end

  def deployment(name) do
    %{
      "apiVersion" => "apps/v1",
      "kind" => "Deployment",
      "metadata" => %{
        "name" => name,
        "namespace" => name
      },
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
            "containers" => [%{"name" => "app", "image" => "nginx"}]
          }
        }
      }
    }
  end

  def ns(name) do
    %{
      "apiVersion" => "v1",
      "kind" => "Namespace",
      "metadata" => %{
        "name" => name
      }
    }
  end
end
