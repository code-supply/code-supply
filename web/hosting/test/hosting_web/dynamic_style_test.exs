defmodule HostingWeb.DynamicStyleTest do
  use ExUnit.Case

  alias HostingWeb.DynamicStyle

  test "only renders styles for associated properties of the map" do
    assert [
             "background-color:#FFFF00",
             "background-image:url(\"http://example.com/foo.jpeg\")"
           ] ==
             DynamicStyle.as_list(%{
               image_url: "http://example.com/foo.jpeg",
               name: "",
               text_color: nil,
               background_colour: "FFFF00"
             })
  end

  test "colours are prefixed with hash" do
    assert [
             "color:#00FF00",
             "background-color:#FFFF00"
           ] ==
             DynamicStyle.as_list(%{
               text_colour: "00FF00",
               background_colour: "FFFF00"
             })
  end
end
