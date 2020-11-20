defmodule Affable.RawTest do
  use Affable.DataCase

  import Affable.SitesFixtures

  alias Affable.Sites.Raw

  describe "raw representations" do
    test "include full sites" do
      site = site_fixture()
      raw_site = site |> Raw.raw()

      assert raw_site["name"] == site.name

      write_fixture_for_external_consumption("raw_site", raw_site)
    end
  end

  defp write_fixture_for_external_consumption(name, obj) do
    (Path.dirname(__ENV__.file) <> "/../../../../fixtures/#{name}.ex")
    |> File.write!(inspect(obj, pretty: true))
  end
end
