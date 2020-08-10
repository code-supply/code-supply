defmodule SiteOperator.Controller.V1.AffiliateSite do
  @moduledoc """
  SiteOperator: AffiliateSite CRD.

  ## Kubernetes CRD Spec

  By default all CRD specs are assumed from the module name, you can override them using attributes.

  ### Examples
  ```
  # Kubernetes API version of this CRD, defaults to value in module name
  @version "v2alpha1"

  # Kubernetes API group of this CRD, defaults to "site-operator.code.supply"
  @group "kewl.example.io"

  The scope of the CRD. Defaults to `:namespaced`
  @scope :cluster

  CRD names used by kubectl and the kubernetes API
  @names %{
    plural: "foos",
    singular: "foo",
    kind: "Foo",
    shortNames: ["f", "fo"]
  }
  ```

  ## Declare RBAC permissions used by this module

  RBAC rules can be declared using `@rule` attribute and generated using `mix bonny.manifest`

  This `@rule` attribute is cumulative, and can be declared once for each Kubernetes API Group.

  ### Examples

  ```
  @rule {apiGroup, resources_list, verbs_list}

  @rule {"", ["pods", "secrets"], ["*"]}
  @rule {"apiextensions.k8s.io", ["foo"], ["*"]}
  ```

  ## Add additional printer columns

  Kubectl uses server-side printing. Columns can be declared using `@additional_printer_columns` and generated using `mix bonny.manifest`

  [Additional Printer Columns docs](https://kubernetes.io/docs/tasks/access-kubernetes-api/custom-resources/custom-resource-definitions/#additional-printer-columns)

  ### Examples

  ```
  @additional_printer_columns [
    %{
      name: "test",
      type: "string",
      description: "test",
      JSONPath: ".spec.test"
    }
  ]
  ```

  """
  use Bonny.Controller
  require Logger

  # @group "your-operator.your-domain.com"
  # @version "v1"

  @scope :cluster
  @names %{
    plural: "affiliatesites",
    singular: "affiliatesite",
    kind: "AffiliateSite",
    shortNames: ["as"]
  }

  @additional_printer_columns [
    %{
      name: "domain",
      type: "string",
      description: "Domain name of the website",
      JSONPath: ".spec.domain"
    }
  ]

  @rule {"", ["namespaces", "services"], ["create", "delete"]}
  @rule {"apps", ["deployments"], ["create", "delete"]}
  @rule {"networking.istio.io", ["gateways", "virtualservices"], ["create", "delete"]}
  @rule {"cert-manager.io", ["certificates"], ["create", "delete"]}

  @spec add(map()) :: :ok | :error
  @impl Bonny.Controller
  def add(%{"metadata" => %{"name" => name}, "spec" => %{"domain" => domain}}) do
    log_metadata = [action: "add", name: name, domain_name: domain]

    case affiliate_site().create(name, domain) do
      {:ok, _} ->
        Logger.info("created", log_metadata)
        :ok

      {:error, message} ->
        Logger.error(message, log_metadata)
        :error
    end
  end

  @spec modify(map()) :: :ok | :error
  @impl Bonny.Controller
  def modify(%{}) do
    Logger.info("modify", action: "modify")
    :ok
  end

  @spec delete(map()) :: :ok | :error
  @impl Bonny.Controller
  def delete(%{"metadata" => %{"name" => name}}) do
    log_metadata = [action: "delete", name: name]

    case affiliate_site().delete(name) do
      {:ok, _} ->
        Logger.info("deleted", log_metadata)
        :ok

      {:error, message} ->
        Logger.error(message, log_metadata)
        :error
    end
  end

  @spec reconcile(map()) :: :ok | :error
  @impl Bonny.Controller
  def reconcile(%{}) do
    Logger.info("reconcile", action: "reconcile")
    :ok
  end

  defp affiliate_site do
    Application.get_env(:site_operator, :affiliate_site)
  end
end
