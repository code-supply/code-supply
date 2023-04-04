defmodule Hosting.CssGrid do
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

  @spec delete_area(t(), area()) :: t()
  def delete_area(%{areas: areas, rows: rows} = grid, area) do
    case full_columns_for_area(areas, area) do
      [] ->
        {new_areas, removed_row_indices} =
          for {row, idx} <- Enum.with_index(areas), reduce: {[], []} do
            {acc, acc_removed_row_indices} ->
              subsequent_rows = Enum.drop(areas, idx + 1)
              other_areas_in_row = MapSet.new(Enum.filter(row, fn a -> a != area end))

              all_other_areas_present_in_subsequent_row =
                Enum.all?(other_areas_in_row, fn other_area ->
                  Enum.any?(subsequent_rows, fn other_row -> other_area in other_row end)
                end)

              cond do
                area not in row ->
                  {acc ++ [row], acc_removed_row_indices}

                all_other_areas_present_in_subsequent_row ->
                  {acc, [idx | acc_removed_row_indices]}

                true ->
                  {acc ++ [row_without_area(areas, row, area)], acc_removed_row_indices}
              end
          end

        %{
          grid
          | areas: new_areas,
            rows:
              for idx <- removed_row_indices, reduce: rows do
                acc ->
                  List.delete_at(acc, idx)
              end
        }

      cols ->
        for {col, deletion_offset} <- Enum.with_index(cols), reduce: grid do
          acc ->
            delete_column(acc, col - deletion_offset)
        end
    end
  end

  def full_columns_for_area(areas, area) do
    column_indices =
      for row <- areas, reduce: [] do
        acc ->
          column_indices_for_row =
            for {a, idx} <- Enum.with_index(row), reduce: [] do
              acc_indices ->
                if a == area do
                  acc_indices ++ [idx]
                else
                  acc_indices
                end
            end

          case column_indices_for_row do
            [] ->
              acc

            indices ->
              acc ++ indices
          end
      end

    column_indices
    |> Enum.uniq()
    |> Enum.filter(fn idx ->
      length(areas) == Enum.count(column_indices, fn i -> i == idx end)
    end)
  end

  @spec delete_column(t(), non_neg_integer()) :: t()
  def delete_column(%{areas: areas, columns: columns} = grid, col) do
    %{
      grid
      | areas: for(row <- areas, do: List.delete_at(row, col)),
        columns: List.delete_at(columns, col)
    }
  end

  @spec row_without_area(areas(), list(area()), area()) :: list(area())
  defp row_without_area(areas, row, area) do
    replacement =
      Enum.find(row, fn a ->
        a != area and areas_adjacent?(row, a, area) and !extends_vertically?(areas, area)
      end)

    for a <- row do
      if a == area do
        replacement
      else
        a
      end
    end
  end

  @spec areas_adjacent?(list(area()), area(), area()) :: boolean()
  defp areas_adjacent?(row, area1, area2) do
    {whether_adjacent, _} =
      Enum.reduce_while(row, {false, nil}, fn area, {whether_adjacent, previous_area} ->
        case {area, previous_area} do
          {^area1, ^area2} ->
            {:halt, {true, area}}

          {^area2, ^area1} ->
            {:halt, {true, area}}

          {_, _} ->
            {:cont, {whether_adjacent, area}}
        end
      end)

    whether_adjacent
  end

  @spec extends_vertically?(areas(), area()) :: boolean()
  defp extends_vertically?(areas, area) do
    {result, _} =
      Enum.reduce_while(areas, {false, false}, fn row, {whether_extends, seen_before} ->
        cond do
          seen_before and area in row ->
            {:halt, {true, true}}

          area in row ->
            {:cont, {whether_extends, true}}

          true ->
            {:cont, {whether_extends, seen_before}}
        end
      end)

    result
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
