defmodule AffableWeb.LayoutView do
  use AffableWeb, :view

  def render("root.json", %{conn: %{assigns: %{k8s: k8s}}}) do
    k8s
  end
end
