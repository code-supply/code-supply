defmodule Affable.PageTitleUtils do
  use ExUnit.Case, async: true

  import Affable.Sites.PageTitleUtils, only: [generate: 1, to_path: 1]

  test "given pages with custom names, gives 'Untitled page'" do
    assert "Untitled page" ==
             generate(["Home", "Contact Us"])
  end

  test "given a list that has an Untitled page, gives 'Untitled page 2'" do
    assert "Untitled page 2" ==
             generate(["Home", "Contact Us", "Untitled page"])
  end

  test "given an 'Untitled page 20', gives 'Untitled page 21'" do
    assert "Untitled page 21" ==
             generate(["Home", "Contact Us", "Untitled page 20", "Untitled page"])
  end

  test "given an 'Untitled page poop', gives 'Untitled page'" do
    assert "Untitled page" ==
             generate(["Home", "Contact Us", "Untitled page poop"])
  end

  test "given page 1-10, gives 11" do
    assert "Untitled page 11" ==
             generate([
               "Untitled page 1",
               "Untitled page 2",
               "Untitled page 3",
               "Untitled page 4",
               "Untitled page 5",
               "Untitled page 6",
               "Untitled page 7",
               "Untitled page 8",
               "Untitled page 9",
               "Untitled page 10"
             ])
  end

  test "can convert a title to a path" do
    assert "/untitled-page-11" ==
             generate(["Home", "Contact Us", "Untitled page 10"]) |> to_path()
  end
end
