defmodule SiteOperator.Domain do
  def internal_hostname(domain) do
    "app." <> String.replace_suffix(domain, ".affable.app", "")
  end

  def is_affable?(domain) do
    String.ends_with?(domain, ".affable.app")
  end
end
