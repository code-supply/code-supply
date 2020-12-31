defmodule Affable.SiteUpdater do
  @behaviour Affable.Broadcaster

  alias Affable.Sites.Site

  import Affable.Sites.Raw

  @impl true
  def broadcast(%Site{} = site) do
    case http().put(payload(site), "http://#{site.internal_hostname}/") do
      {:ok, _} ->
        :ok
    end
  end

  defp payload(%Site{} = site) do
    %Affable.Messages.WholeSite{
      preview: raw(site),
      published: site.latest_publication.data
    }
    |> Map.from_struct()
  end

  defp http() do
    Application.get_env(:affable, :http)
  end
end
