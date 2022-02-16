defmodule Affable.CssGridTest do
  use ExUnit.Case, async: true

  alias Affable.CssGrid

  test "intersperses adjusters, which have editor pos and original pos" do
    assert %CssGrid{
             bar: "2px",
             rows: [
               "calc(10px - 2px)",
               "2px",
               "20px",
               "calc(30px - 2px)",
               "2px",
               "calc(40px - 2px)",
               "2px",
               "calc(50px - 2px)",
               "2px"
             ],
             columns: [
               "calc(50px - 2px)",
               "2px",
               "calc(40px - 2px)",
               "2px",
               "calc(30px - 2px)",
               "2px"
             ],
             areas: [
               ~w(a               a                 _adjustcolumn_1_1 b                 b               ),
               ~w(_adjustrow_0_0  _adjustrow_0_0    _adjustrow_0_0    _adjustrow_0_0    _adjustrow_0_0  ),
               ~w(c               _adjustcolumn_0_0 d                 d                 d               ),
               ~w(c               _adjustcolumn_0_0 d                 d                 d               ),
               ~w(c               _adjustcolumn_0_0 _adjustrow_3_2    _adjustrow_3_2    _adjustrow_3_2  ),
               ~w(c               _adjustcolumn_0_0 e                 _adjustcolumn_2_1 f               ),
               ~w(_adjustrow_5_3  _adjustrow_5_3    _adjustrow_5_3    _adjustrow_5_3    _adjustrow_5_3  ),
               ~w(g               g                 g                 g                 g               ),
               ~w(_adjustrow_7_4  _adjustrow_7_4    _adjustrow_7_4    _adjustrow_7_4    _adjustrow_7_4  )
             ]
           } ==
             CssGrid.add_adjusters(%CssGrid{
               bar: "2px",
               rows: ["10px", "20px", "30px", "40px", "50px"],
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

  test "can extract editor pos and original pos from a name" do
    assert 4 == CssGrid.editor_pos("_adjustrow_4_2")
    assert 2 == CssGrid.original_pos("_adjustrow_5_2")
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

  test "produces a unique list of names with coords, for looking up elements to measure from frontend" do
    assert [
             {"f", {2, 0}},
             {"a", {1, 1}},
             {"b", {2, 1}},
             {"c", {0, 4}},
             {"d", {2, 3}},
             {"e", {2, 4}}
           ] ==
             CssGrid.names_with_coords([
               ["f", "f", "f"],
               ["a", "a", "b"],
               ["c", "d", "d"],
               ["c", "d", "d"],
               ["c", "e", "e"]
             ])
  end
end
