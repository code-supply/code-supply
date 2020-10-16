defmodule AffableWeb.AffiliateSitesLiveTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Affable.SitesFixtures
  import Hammox

  alias Affable.{Accounts, Sites}

  setup :verify_on_exit!

  setup do
    %{site: site_fixture()}
  end

  defp path(conn, site) do
    Routes.affiliate_sites_path(conn, :edit, site.id)
  end

  describe "authenticated user" do
    setup context do
      %{conn: conn, user: user} = register_and_log_in_user(context)
      %{conn: conn, user: user, site: site_fixture(user)}
    end

    test "can create new item", %{conn: conn, user: user, site: site} do
      {:ok, view, _html} = live(conn, path(conn, site))

      num_items = site.items |> length()

      refute view
             |> has_element?(".item:nth-child(#{num_items + 1})")

      stub(Affable.MockBroadcaster, :broadcast, fn _message -> :ok end)

      view
      |> element("#new-item")
      |> render_click()

      assert Sites.get_site!(user, site.id).items
             |> length() == num_items + 1

      assert view
             |> has_element?(".item:nth-child(#{num_items + 1})")
    end

    test "creating an item broadcasts the change", %{conn: conn, site: site} do
      {:ok, view, _html} = live(conn, path(conn, site))

      expect(Affable.MockBroadcaster, :broadcast, fn %{items: [item | _]} ->
        assert item.name == "New item"
        :ok
      end)

      view
      |> element("#new-item")
      |> render_click()
    end

    test "can edit an item", %{conn: conn, site: site} do
      conn = get(conn, path(conn, site))
      assert html_response(conn, 200)

      {:ok, view, html} = live(conn, path(conn, site))

      [first_item | _] = site.items

      assert html =~ first_item.description

      stub(Affable.MockBroadcaster, :broadcast, fn _message -> :ok end)

      assert render_first_item_change(view, site.items, %{
               "description" => "My new description!"
             }) =~ "My new description!"
    end

    test "editing an item broadcasts the change to the site", %{conn: conn, site: site} do
      conn = get(conn, path(conn, site))

      {:ok, view, _html} = live(conn, path(conn, site))

      expected_message = Sites.raw(%{site | name: "new name"})

      expect(Affable.MockBroadcaster, :broadcast, fn ^expected_message -> :ok end)

      render_change(view, :save, %{
        "site" => %{
          "name" => "new name"
        }
      })
    end

    test "editing an item shows the user that the change was saved", %{conn: conn, site: site} do
      conn = get(conn, path(conn, site))

      {:ok, view, before_save} = live(conn, path(conn, site))

      # glitches on load when the element present, so ensure it's not present
      refute before_save =~ "saved-state"
      refute before_save =~ "Saved."

      stub(Affable.MockBroadcaster, :broadcast, fn _message -> :ok end)

      after_save =
        render_change(view, :save, %{
          "site" => %{
            "name" => "new name"
          }
        })

      assert after_save =~ "saved-state saved"
      assert after_save =~ "Saved."

      send(view.pid, :clear_save)
      after_timeout = view |> render()

      assert after_timeout =~ "saved-state clear"
      assert after_timeout =~ "Saved."
    end

    test "editing an item to be invalid marks the item as invalid", %{conn: conn, site: site} do
      {:ok, view, _html} = live(conn, path(conn, site))

      result =
        render_first_item_change(view, site.items, %{
          "name" => ""
        })

      assert result =~ "phx-feedback-for=\"site_items_0_name"
      assert result =~ "Whoops!"
    end

    test "can reorder an item", %{conn: conn, site: site} do
      {:ok, view, _html} = live(conn, path(conn, site))

      [first_item | _] = site.items

      assert view |> has_element?("#position-#{first_item.id}", "1")

      stub(Affable.MockBroadcaster, :broadcast, fn _message -> :ok end)

      view
      |> element("#demote-#{first_item.id}")
      |> render_click()

      assert view |> has_element?("#position-#{first_item.id}", "2")

      view
      |> element("#promote-#{first_item.id}")
      |> render_click()

      assert view |> has_element?("#position-#{first_item.id}", "1")
      assert view |> has_element?(".saved-state.saved")
    end

    test "reordering broadcasts the change to the site", %{conn: conn, site: site} do
      {:ok, view, _html} = live(conn, path(conn, site))

      [first_item | _] = site.items

      expect(Affable.MockBroadcaster, :broadcast, fn %{items: [_, new_second_item | _]} ->
        assert first_item.name == new_second_item.name
        :ok
      end)

      view
      |> element("#demote-#{first_item.id}")
      |> render_click()

      expect(Affable.MockBroadcaster, :broadcast, fn %{items: [new_first_item | _]} ->
        assert first_item.name == new_first_item.name
        :ok
      end)

      view
      |> element("#promote-#{first_item.id}")
      |> render_click()
    end

    test "raises exception when site doesn't belong to user", %{conn: conn} do
      site = site_fixture()

      assert_raise Ecto.NoResultsError, fn -> get(conn, path(conn, site)) end
    end

    test "redirects to login page when token is bogus", %{conn: conn, user: user, site: site} do
      Accounts.delete_user(user)

      conn = get(conn, path(conn, site))
      assert html_response(conn, 302)

      expected_path = Routes.user_session_path(conn, :new)

      {:error, {:redirect, %{to: actual_path}}} = live(conn, path(conn, site))

      assert actual_path == expected_path
    end

    defp render_first_item_change(view, items, attrs) do
      [first_item | other_items] = items

      render_change(view, :save, %{
        "_method" => "put",
        "_target" => ["site", "items", "0", "name"],
        "site" => %{
          "items" =>
            Map.merge(
              %{
                "0" =>
                  Map.merge(
                    %{
                      "id" => "#{first_item.id}",
                      "name" => first_item.name,
                      "description" => first_item.description
                    },
                    attrs
                  )
              },
              item_params(other_items, from: 1)
            )
        }
      })
    end

    defp item_params([], from: _n) do
      %{}
    end

    defp item_params([item | items], from: n) do
      Map.merge(
        %{
          "#{n}" => %{
            "id" => "#{item.id}",
            "name" => "#{item.name}",
            "description" => "#{item.description}"
          }
        },
        item_params(items, from: n + 1)
      )
    end
  end

  describe "not authenticated" do
    test "redirects to login page when not logged in", %{conn: conn, site: site} do
      conn = get(conn, path(conn, site))
      assert html_response(conn, 302)

      expected_path = Routes.user_session_path(conn, :new)

      {:error, {:redirect, %{to: actual_path}}} = live(conn, path(conn, site))

      assert actual_path == expected_path
    end
  end
end
