defmodule SiteOperator.Domain do
  def is_affable?(domain) do
    String.ends_with?(domain, ".affable.app")
  end
end
