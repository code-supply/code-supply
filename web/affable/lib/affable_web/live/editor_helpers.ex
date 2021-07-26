defmodule AffableWeb.EditorHelpers do
  import Phoenix.HTML.Form

  def editor_textarea(form, field, opts \\ []) do
    textarea(
      form,
      field,
      opts ++ [phx_debounce: 250, phx_hook: "MaintainAttrs", data_attrs: "style"]
    )
  end
end
