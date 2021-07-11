defmodule SiteOperator.Domain do
  def internal_hostname(domain) do
    "app." <> String.replace_suffix(domain, ".affable.app", "")
  end

  def is_affable?(domain) do
    String.ends_with?(domain, ".affable.app")
  end

  def any_custom?(domains) do
    Enum.any?(domains, &(!is_affable?(&1)))
  end
end
