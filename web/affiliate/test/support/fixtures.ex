defmodule Affiliate.Fixtures do
  def fixture(name) do
    {incoming_payload, _} =
      (Path.dirname(__ENV__.file) <> "/../../../fixtures/#{name}.ex")
      |> Code.eval_file()

    incoming_payload
  end
end
