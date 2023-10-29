defmodule HostingWeb.DynamicStyleTest do
  use ExUnit.Case

  alias HostingWeb.DynamicStyle

  test "only renders styles for associated properties of the map" do
    assert [
             "background-color:#FFFF00",
             "background-image:url(\"http://example.com/foo.jpeg\")"
           ] ==
             %{
               image_url: "http://example.com/foo.jpeg",
               name: "",
               text_color: nil,
               background_colour: "FFFF00"
             }
             |> DynamicStyle.as_list()
             |> Enum.sort()
  end

  test "colours are prefixed with hash" do
    assert [
             "background-color:#FFFF00",
             "color:#00FF00"
           ] ==
             %{
               text_colour: "00FF00",
               background_colour: "FFFF00"
             }
             |> DynamicStyle.as_list()
             |> Enum.sort()
  end
end
