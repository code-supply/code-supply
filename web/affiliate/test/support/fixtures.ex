defmodule Affiliate.Fixtures do
  def site_update_message do
    {incoming_payload, _} =
      (Path.dirname(__ENV__.file) <> "/../../../fixtures/site_update_message.ex")
      |> Code.eval_file()

    incoming_payload
  end
end
