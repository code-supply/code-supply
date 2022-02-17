defmodule AffiliateWeb.PageView do
  use AffiliateWeb, :view

  def section_style(section) do
    Enum.join(AffiliateWeb.DynamicStyle.as_list(section), ";")
  end
end
