defmodule SiteOperator.K8sFactories do
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
            "affable-app" => namespace_name
          }
        },
        "template" => %{
          "metadata" => %{
            "labels" => %{
              "affable-app" => namespace_name
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
