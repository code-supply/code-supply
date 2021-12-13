defmodule Affable.SiteUpdaterTest do
  use Affable.DataCase, async: true

  import Hammox
  import Affable.AccountsFixtures
  import Affable.SitesFixtures

  alias Affable.MockHTTP
  alias Affable.{Broadcaster, Sites, SiteUpdater}
  alias Affable.Assets.Asset
  alias Affable.Sites.{Page, Section, Site}

  setup :verify_on_exit!

  setup_all do
    Hammox.protect(SiteUpdater, Broadcaster)
  end

  test "can broadcast full site on demand", %{broadcast_1: broadcast} do
    user = user_fixture()
    site = site_fixture(user) |> Sites.reload_assets()
    [first_asset | _] = site.assets
    stub_broadcast()
    {:ok, %Page{} = page} = Sites.add_page(site, user)
    {:ok, %Page{sections: [section]} = page} = Sites.add_page_section(page, user)

    {:ok, _} =
      Sites.update_page(
        page,
        %{
          sections: [
            %{
              id: section.id,
              image_id: first_asset.id
            }
          ]
        },
        user
      )

    {:ok, %Page{}} = Sites.add_page_section(page, user)

    %Site{pages: [_ | [%Page{sections: [%Section{} = section | _]} | _]]} =
      site = Sites.get_site!(site.id)

    assert %Asset{} = section.image

    site = %{site | id: 1}

    expected_name = site.name

    expected_url = "http://#{site.internal_hostname}/"

    expect(MockHTTP, :put, fn message, ^expected_url ->
      assert %{
               preview: %{"name" => ^expected_name},
               published: %{"name" => ^expected_name}
             } = message

      message
      |> put_in([:preview, "id"], 1)
      |> put_in([:published, "id"], 1)
      |> write_fixture_for_external_consumption("site_update_message")

      {:ok, %{}}
    end)

    assert broadcast.(site) == :ok
  end

  defp write_fixture_for_external_consumption(obj, name) do
    (Path.dirname(__ENV__.file) <> "/../../../fixtures/#{name}.ex")
    |> File.write!(
      inspect(
        for {key, val} <- obj, into: %{} do
          {Atom.to_string(key), val}
        end,
        pretty: true
      )
    )
  end
end
