defmodule Affable.CssGridTest do
  use ExUnit.Case, async: true

  alias Affable.CssGrid

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
