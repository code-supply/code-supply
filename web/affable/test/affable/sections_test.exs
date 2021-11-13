defmodule Affable.SectionsTest do
  use Affable.DataCase, async: true

  alias Affable.Sites.Section

  test "names are a-z, 0-9 or dash, nothing else" do
    name = fn s -> Section.changeset(%Section{}, %{name: s}) end

    assert name.("hithere").valid?
    assert name.("hi-there").valid?

    refute name.("Hithere").valid?
    refute name.("with_underscores").valid?
    refute name.("with spaces").valid?
  end
end
