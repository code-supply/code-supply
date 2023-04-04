defmodule Hosting.CssGridTest do
  use ExUnit.Case, async: true

  alias Hosting.CssGrid

  test "can delete the main section of the common header-nav-main-footer layout" do
    assert %CssGrid{
             bar: "2px",
             rows: ~w(10px 10px 10px),
             columns: ~w(50px 40px 30px),
             areas: [
               ~w(h h),
               ~w(n n),
               ~w(f f)
             ]
           } ==
             CssGrid.delete_area(
               %CssGrid{
                 bar: "2px",
                 rows: ~w(10px 10px 10px),
                 columns: ~w(50px 40px 30px),
                 areas: [
                   ~w(h h),
                   ~w(n m),
                   ~w(f f)
                 ]
               },
               "m"
             )
  end

  test "removing last section in row removes the row" do
    assert %CssGrid{
             bar: "2px",
             rows: ~w(10px 10px),
             columns: ~w(50px 40px 30px),
             areas: [
               ~w(a a b),
               ~w(d d d)
             ]
           } ==
             CssGrid.delete_area(
               %CssGrid{
                 bar: "2px",
                 rows: ~w(10px 10px 10px),
                 columns: ~w(50px 40px 30px),
                 areas: [
                   ~w(a a b),
                   ~w(c c c),
                   ~w(d d d)
                 ]
               },
               "c"
             )
  end

  test "removing a section that leaves sections continued on other rows removes the rows" do
    assert %CssGrid{
             bar: "2px",
             rows: ~w(10px 30px),
             columns: ~w(50px 40px 30px),
             areas: [
               ~w(a a b),
               ~w(d f f)
             ]
           } ==
             CssGrid.delete_area(
               %CssGrid{
                 bar: "2px",
                 rows: ~w(10px 20px 30px),
                 columns: ~w(50px 40px 30px),
                 areas: [
                   ~w(a a b),
                   ~w(d c c),
                   ~w(d f f)
                 ]
               },
               "c"
             )
  end

  test "removing a section doesn't remove rows that contain other unique sections" do
    assert %CssGrid{
             bar: "2px",
             rows: ~w(10px 20px 30px 40px),
             columns: ~w(50px 40px 30px),
             areas: [
               ~w(a a a),
               ~w(d b b),
               ~w(d e e),
               ~w(d e e)
             ]
           } ==
             CssGrid.delete_area(
               %CssGrid{
                 bar: "2px",
                 rows: ~w(10px 20px 30px 40px),
                 columns: ~w(50px 40px 30px),
                 areas: [
                   ~w(a a a),
                   ~w(d b c),
                   ~w(d e e),
                   ~w(d e e)
                 ]
               },
               "c"
             )
  end

  test "removing a section that was the only one in a column removes the column" do
    assert %CssGrid{
             bar: "2px",
             rows: ~w(10px 20px 30px 40px),
             columns: ~w(40px 30px),
             areas: [
               ~w(b b),
               ~w(b b),
               ~w(c c),
               ~w(c c)
             ]
           } ==
             CssGrid.delete_area(
               %CssGrid{
                 bar: "2px",
                 rows: ~w(10px 20px 30px 40px),
                 columns: ~w(50px 40px 30px),
                 areas: [
                   ~w(a b b),
                   ~w(a b b),
                   ~w(a c c),
                   ~w(a c c)
                 ]
               },
               "a"
             )
  end

  test "removing a section that was the only one in multiple columns removes the columns" do
    assert %CssGrid{
             bar: "2px",
             rows: ~w(10px 20px 30px 40px),
             columns: ~w(40px 30px),
             areas: [
               ~w(b b),
               ~w(b b),
               ~w(c c),
               ~w(c c)
             ]
           } ==
             CssGrid.delete_area(
               %CssGrid{
                 bar: "2px",
                 rows: ~w(10px 20px 30px 40px),
                 columns: ~w(10px 50px 40px 30px),
                 areas: [
                   ~w(a a b b),
                   ~w(a a b b),
                   ~w(a a c c),
                   ~w(a a c c)
                 ]
               },
               "a"
             )
  end

  test "adds adjusters to top and right of grid" do
    assert %CssGrid{
             bar: "2px",
             rows: ["2px", "10px", "20px", "1fr", "40px", "50px"],
             columns: ["50px", "40px", "30px", "2px"],
             areas: [
               ["_adjustcolumn_0", "_adjustcolumn_1", "_adjustcolumn_2", "_adjustrow_0"],
               ["a", "a", "b", "_adjustrow_0"],
               ["c", "d", "d", "_adjustrow_1"],
               ["c", "d", "d", "_adjustrow_2"],
               ["c", "e", "f", "_adjustrow_3"],
               ["g", "g", "g", "_adjustrow_4"]
             ]
           } ==
             CssGrid.add_adjusters(%CssGrid{
               bar: "2px",
               rows: ["10px", "20px", "1fr", "40px", "50px"],
               columns: ["50px", "40px", "30px"],
               areas: [
                 ["a", "a", "b"],
                 ["c", "d", "d"],
                 ["c", "d", "d"],
                 ["c", "e", "f"],
                 ["g", "g", "g"]
               ]
             })
  end

  test "doesn't add adjusters to single-row lists" do
    assert %CssGrid{
             bar: "3px",
             rows: ["20px"],
             columns: [],
             areas: [~w(a a a)]
           } ==
             CssGrid.add_adjusters(%CssGrid{
               bar: "3px",
               rows: ["20px"],
               columns: [],
               areas: [~w(a a a)]
             })
  end

  test "produces a unique list of names from a grid" do
    assert ~w(a b c d e f) ==
             CssGrid.names([
               ["a", "a", "b"],
               ["c", "d", "d"],
               ["c", "d", "d"],
               ["c", "e", "e"],
               ["f", "f", "f"]
             ])
  end
end
