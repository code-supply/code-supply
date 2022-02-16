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

  def add_adjusters(css_grid) do
    css_grid
    |> insert_col_adjusters()
    |> pad()
    |> insert_row_adjusters()
    |> pad()
  end

  def editor_pos(name) do
    extract_pos(name, 2)
  end

  def original_pos(name) do
    extract_pos(name, 3)
  end

  defp extract_pos(name, name_index) do
    case String.split(name, "_") do
      [_underscore, _area, _editor_pos, _original_pos] = bits ->
        {n, _junk} = Integer.parse(Enum.at(bits, name_index))
        n

      _ ->
        nil
    end
  end

  def names(grid) do
    grid
    |> List.flatten()
    |> Enum.uniq()
  end

  @spec names_with_coords(areas) :: areas
  def names_with_coords(areas) do
    for {row, y} <- Enum.with_index(areas), reduce: [] do
      acc ->
        for {name, x} <- Enum.with_index(row), reduce: acc do
          inner_acc ->
            {replaced, lst} =
              for {cursor_name, cursor_coords} <- inner_acc, reduce: {false, []} do
                {replaced, lst} ->
                  if cursor_name == name do
                    {true, lst ++ [{cursor_name, {x, y}}]}
                  else
                    {replaced, lst ++ [{cursor_name, cursor_coords}]}
                  end
              end

            if replaced do
              lst
            else
              lst ++ [{name, {x, y}}]
            end
        end
    end
  end

  @spec insert_col_adjusters(t()) :: t()
  defp insert_col_adjusters(
         %__MODULE__{
           bar: bar_width,
           columns: column_sizes,
           areas: areas
         } = css_grid
       ) do
    {new_grid, new_column_sizes} =
      for original_row <- areas, reduce: {[], column_sizes} do
        {acc_grid, acc_column_sizes} ->
          {_, new_row, new_column_sizes} =
            for {name, x} <- Enum.with_index(original_row), reduce: {0, [], acc_column_sizes} do
              {offset, row, col_sizes} ->
                identical_pair? = name == Enum.at(original_row, x - 1)

                if x == 0 or identical_pair? do
                  {offset, row ++ [name], col_sizes}
                else
                  add_resizable_column(row, name, x, offset, col_sizes, bar_width)
                end
            end

          {acc_grid ++ [new_row], new_column_sizes}
      end

    %{css_grid | columns: List.flatten(new_column_sizes), areas: new_grid}
  end

  defp add_resizable_column(row, name, x, offset, col_sizes, bar_width) do
    editor_pos = x + offset - 1
    original_pos = x - 1

    {
      offset + 1,
      row ++ ["_adjustcolumn_#{editor_pos}_#{original_pos}", name],
      add_bar_size(col_sizes, bar_width, editor_pos)
    }
  end

  @spec insert_row_adjusters(t()) :: t()
  defp insert_row_adjusters(%__MODULE__{bar: bar_width, rows: row_sizes, areas: areas} = css_grid) do
    {_, new_grid, new_row_sizes} =
      for {row, y} <- Enum.with_index(areas), reduce: {0, areas, row_sizes} do
        {added_row_count, acc_grid, acc_row_sizes} ->
          editor_pos = y + added_row_count

          case adjuster_for_row(
                 acc_grid,
                 editor_pos,
                 "_adjustrow_#{editor_pos}_#{y}",
                 row
               ) do
            {:not_adjusted, _} ->
              {
                added_row_count,
                acc_grid,
                acc_row_sizes
              }

            {:adjusted, adjuster_row} ->
              {
                added_row_count + 1,
                List.insert_at(acc_grid, editor_pos + 1, adjuster_row),
                add_bar_size(acc_row_sizes, bar_width, y)
              }
          end
      end

    %{css_grid | rows: List.flatten(new_row_sizes), areas: new_grid}
  end

  @spec add_bar_size(
          sizes :: list(measurement),
          bar_width :: measurement,
          pos :: non_neg_integer()
        ) ::
          list(String.t())
  defp add_bar_size(sizes, bar_width, pos) do
    List.update_at(sizes, pos, fn
      [size, bar] ->
        [size, bar]

      size ->
        ["calc(#{size} - #{bar_width})", bar_width]
    end)
  end

  defp adjuster_for_row(acc_grid, y, adjuster_name, row) do
    for {name, x} <- Enum.with_index(row), reduce: {:not_adjusted, row} do
      {adjusters_added, acc_adjuster_row} ->
        if y == bottom(acc_grid, name) do
          {:adjusted, List.replace_at(acc_adjuster_row, x, adjuster_name)}
        else
          {adjusters_added, acc_adjuster_row}
        end
    end
  end

  @spec pad(t()) :: t()
  defp pad(%__MODULE__{areas: areas} = css_grid) do
    length_of_widest_row = areas |> Enum.map(&length(&1)) |> Enum.max()

    new_grid =
      for row <- areas do
        if length(row) < length_of_widest_row do
          List.insert_at(row, length_of_widest_row, List.last(row))
        else
          row
        end
      end

    %{css_grid | areas: new_grid}
  end

  defp bottom(areas, name) do
    top(areas, name) + height(areas, name) - 1
  end

  defp top(areas, name) do
    Enum.find_index(areas, fn cols ->
      Enum.any?(cols, &(&1 == name))
    end)
  end

  defp height(areas, name) do
    length(areas) - top(Enum.reverse(areas), name) - top(areas, name)
  end
end
