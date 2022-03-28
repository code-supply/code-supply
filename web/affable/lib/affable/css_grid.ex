defmodule Affable.CssGrid do
  @enforce_keys [:bar, :columns, :rows, :areas]
  defstruct [:bar, :columns, :rows, :areas]

  @type area :: String.t()
  @type measurement :: String.t()
  @type areas :: list(list(area))

  @type t :: %__MODULE__{
          bar: String.t(),
          rows: list(measurement),
          columns: list(measurement),
          areas: list(list(area))
        }

  @spec add_adjusters(t()) :: t()
  def add_adjusters(%__MODULE__{areas: [_single_row]} = css_grid) do
    css_grid
  end

  def add_adjusters(
        %__MODULE__{
          bar: bar,
          areas: areas,
          rows: rows,
          columns: columns
        } = css_grid
      ) do
    %__MODULE__{
      css_grid
      | areas: areas |> add_column_adjusters() |> add_row_adjusters(),
        rows: [bar | rows],
        columns: columns ++ [bar]
    }
  end

  @spec add_column_adjusters(areas()) :: areas()
  defp add_column_adjusters([first_row | _] = areas) do
    [
      for {_, x} <- Enum.with_index(first_row) do
        "_adjustcolumn_#{x}"
      end
      | areas
    ]
  end

  @spec add_row_adjusters(areas()) :: areas()
  defp add_row_adjusters([first_row | rest]) do
    [
      first_row ++ ["_adjustrow_0"]
      | for {row, y} <- Enum.with_index(rest) do
          row ++ ["_adjustrow_#{y}"]
        end
    ]
  end

  def names(grid) do
    grid
    |> List.flatten()
    |> Enum.uniq()
  end
end
