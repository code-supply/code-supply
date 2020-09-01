defmodule Affable.IDTest do
  use ExUnit.Case, async: true

  import Affable.ID

  test "can round-trip a number" do
    assert site_name_from_id(123) |> id_from_site_name() == 123
  end
end
