defmodule Mix.Tasks.App.Version do
  use Mix.Task

  def run(_) do
    "VERSION"
    |> File.read!()
    |> String.trim()
    |> IO.puts()
  end
end
