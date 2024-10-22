defmodule Cv do
  import Mudbrick

  def generate do
    new()
    |> render()
    |> IO.puts()
  end
end
