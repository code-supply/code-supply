defmodule Affable.Sites.PageTitleUtils do
  @default "Untitled page"
  @default_path "/untitled-page"

  def generate(paths) do
    case paths
         |> sort()
         |> Enum.find(&String.starts_with?(&1, @default_path)) do
      nil ->
        @default

      @default_path ->
        "#{@default} 2"

      path ->
        case untitled_number(path) do
          {:ok, number} ->
            "#{@default} #{number + 1}"

          {:error, _} ->
            @default
        end
    end
  end

  def to_path(title) do
    "/" <> Regex.replace(~r/[^a-zA-Z0-9]/, String.downcase(title), "-")
  end

  defp sort(paths) do
    Enum.sort_by(paths, fn path ->
      case untitled_number(path) do
        {:ok, number} ->
          -number

        {:error, _} ->
          0
      end
    end)
  end

  defp untitled_number(path) do
    case Regex.named_captures(~r/#{@default_path}-(?<number>\d+)/, path) do
      %{"number" => number} ->
        {:ok, String.to_integer(number)}

      _ ->
        {:error, ""}
    end
  end
end
