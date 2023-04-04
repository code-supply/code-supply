defmodule Hosting.Sites.TitleUtilsTest do
  use ExUnit.Case, async: true

  import Hosting.Sites.TitleUtils, only: [generate: 3, to_path: 1]

  @title_match "/untitled-page"
  @title_output "Untitled page"

  test "given some chosen paths, gives 'Untitled page'" do
    assert ["Untitled page"] ==
             generate(["/home", "/contact-us"], @title_match, @title_output)
  end

  test "given a list that has an Untitled page, gives 'Untitled page 2'" do
    assert ["Untitled page", "2"] ==
             generate(["/home", "/contact-us", "/untitled-page"], @title_match, @title_output)
  end

  test "given an 'Untitled page 20', gives 'Untitled page 21'" do
    assert ["Untitled page", "21"] ==
             generate(
               ["/home", "/contact-us", "/untitled-page-20", "/untitled-page"],
               @title_match,
               @title_output
             )
  end

  test "given an 'Untitled page poop', gives 'Untitled page'" do
    assert ["Untitled page"] ==
             generate(
               ["/home", "/contact-us", "/untitled-page-poop"],
               @title_match,
               @title_output
             )
  end

  test "given page 1-10, gives 11" do
    assert ["Untitled page", "11"] ==
             generate(
               [
                 "/untitled-page-1",
                 "/untitled-page-2",
                 "/untitled-page-3",
                 "/untitled-page-4",
                 "/untitled-page-5",
                 "/untitled-page-6",
                 "/untitled-page-7",
                 "/untitled-page-8",
                 "/untitled-page-9",
                 "/untitled-page-10"
               ],
               @title_match,
               @title_output
             )
  end

  test "can convert a title to a path" do
    [str, n] =
      generate(["/home", "/contact-us", "/untitled-page-10"], @title_match, @title_output)

    assert "/untitled-page-11" ==
             "#{str} #{n}"
             |> to_path()
  end
end
