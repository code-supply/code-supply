defmodule Affable.Sites.PageTitleUtils do
  @default "Untitled page"

  def generate(existing_titles) do
    case existing_titles
         |> Enum.sort_by(fn title ->
           case untitled_number(title) do
             {:ok, number} ->
               number

             {:error, _} ->
               0
           end
         end)
         |> Enum.reverse()
         |> Enum.find(&(&1 =~ @default)) do
      nil ->
        @default

      @default ->
        "#{@default} 2"

      title ->
        case untitled_number(title) do
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

  defp untitled_number(title) do
    case Regex.named_captures(~r/#{@default} (?<number>\d+)/, title) do
      %{"number" => number} ->
        {:ok, String.to_integer(number)}

      _ ->
        {:error, ""}
    end
  end
end
