defmodule Affable.Sites.PageTitleUtils do
  def generate(strings, default_match, default_output) do
    case strings
         |> sort(default_match)
         |> Enum.find(&String.starts_with?(&1, default_match)) do
      nil ->
        [default_output]

      ^default_match ->
        [default_output, "#{2}"]

      str ->
        case untitled_number(str, default_match) do
          {:ok, number} ->
            [default_output, "#{number + 1}"]

          {:error, _} ->
            [default_output]
        end
    end
  end

  def to_path(title) do
    "/" <> Regex.replace(~r/[^a-zA-Z0-9]/, String.downcase(title), "-")
  end

  defp sort(strings, default_match) do
    Enum.sort_by(strings, fn str ->
      case untitled_number(str, default_match) do
        {:ok, number} ->
          -number

        {:error, _} ->
          0
      end
    end)
  end

  defp untitled_number(str, default_match) do
    case Regex.named_captures(~r/#{default_match}-(?<number>\d+)/, str) do
      %{"number" => number} ->
        {:ok, String.to_integer(number)}

      _ ->
        {:error, ""}
    end
  end
end
