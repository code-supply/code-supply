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

  def deployment(namespace_name) do
    %{
      "apiVersion" => "apps/v1",
      "kind" => "Deployment",
      "metadata" => %{
        "name" => "deleteme",
        "namespace" => namespace_name
      },
      "spec" => %{
        "selector" => %{
          "matchLabels" => %{
            "so-app" => namespace_name
          }
        },
        "template" => %{
          "metadata" => %{
            "labels" => %{
              "so-app" => namespace_name
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
