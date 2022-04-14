defmodule AffableWeb.DynamicStyle do
  @mapped_styles %{
    :image_url => "background-image",
    :name => "grid-area",
    :text_colour => "color",
    :background_colour => "background-color"
  }

  def as_list(user_values) do
    Enum.reduce(@mapped_styles, [], fn {affable_key, css_key}, acc ->
      case {css_key, Map.get(user_values,affable_key)} do
        {_, ""} ->
          acc

        {_, nil} ->
          acc

        {"color" = css_key, value} ->
          ["#{css_key}:##{value}" | acc]

        {"background-color" = css_key, value} ->
          ["#{css_key}:##{value}" | acc]

        {"background-image" = css_key, value} ->
          ["#{css_key}:url(\"#{value}\")" | acc]

        {_, value} ->
          ["#{css_key}:#{value}" | acc]
      end
    end)
  end
end
