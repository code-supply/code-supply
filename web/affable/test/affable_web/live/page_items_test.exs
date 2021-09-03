defmodule AffableWeb.PageItemsTest do
  use AffableWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Hammox

  alias Affable.Sites
  alias Affable.Sites.{Page, Site}

  setup :verify_on_exit!

  defp path(conn, site) do
    Routes.editor_path(conn, :edit, site.id)
  end

  setup context do
    %{conn: conn, user: user} = register_and_log_in_user(context)
    [site] = user.sites

    %{
      conn: conn,
      user: user,
      site: site |> Sites.with_items() |> Sites.with_pages()
    }
  end

  test "can create / delete new item", %{conn: conn, site: %Site{pages: [page]} = site} do
    {:ok, view, _html} = live(conn, path(conn, site))

    num_items = page.items |> length()

    refute view
           |> has_element?(".item:nth-child(#{num_items + 1})")

    stub_broadcast()

    view
    |> element("#new-item-top")
    |> render_click()

    %Site{pages: [page]} = Sites.get_site!(site.id)

    assert view
           |> has_element?(".item:nth-child(#{num_items + 1})")

    view
    |> element("#delete-item-#{List.last(page.items).id}")
    |> render_click()

    refute view
           |> has_element?(".item:nth-child(#{num_items + 1})")

    assert view
           |> element(".item:nth-child(1) .number")
           |> render() =~
             ">1<"
  end

  test "can edit an item", %{
    conn: conn,
    site: %Site{pages: [%Page{header_image_id: header_image_id, items: items}]} = site
  } do
    conn = get(conn, path(conn, site))
    assert html_response(conn, 200)

    {:ok, view, html} = live(conn, path(conn, site))

    [first_item | _] = items

    first_image_url = first_item.image.url

    assert first_image_url =~ "gs://"

    assert html =~ first_item.description

    copied_asset_id = header_image_id

    expect_broadcast(fn site ->
      [page] = site.pages
      [item | _] = page.items
      assert copied_asset_id == item.image.id
    end)

    refute view
           |> has_element?("#publish")

    render_first_item_change(view, items, %{
      "description" => "My new description!",
      "image_id" => "#{copied_asset_id}"
    })

    assert view
           |> has_element?("#publish")

    assert get(conn, path(conn, site)).resp_body =~ "My new description!"
  end

  @tag :capture_log
  test "editing an item to be invalid marks the item as invalid", %{
    conn: conn,
    site: %Site{pages: [%Page{items: items}]} = site
  } do
    {:ok, view, _html} = live(conn, path(conn, site))

    render_first_item_change(view, items, %{"name" => ""})

    assert view |> has_element?(".invalid-feedback")
  end

  test "can reorder an item", %{conn: conn, site: %Site{pages: [%Page{items: items}]} = site} do
    {:ok, view, _html} = live(conn, path(conn, site))

    [first_item | _] = items

    assert view |> has_element?("#item-#{first_item.id} .number", "1")

    expect_broadcast(fn %Site{pages: [%Page{items: [_, new_second_item | _]}]} ->
      assert first_item.name == new_second_item.name
    end)

    view
    |> element("#demote-#{first_item.id}")
    |> render_click()

    assert view |> has_element?("#item-#{first_item.id} .number", "2")

    expect_broadcast(fn %Site{pages: [%Page{items: [new_first_item | _]}]} ->
      assert first_item.name == new_first_item.name
    end)

    view
    |> element("#promote-#{first_item.id}")
    |> render_click()

    assert view |> has_element?("#item-#{first_item.id} .number", "1")
  end

  defp render_first_item_change(view, items, attrs) do
    [first_item | other_items] = items

    render_change(view |> element("#page-#{first_item.page_id}"), %{
      "page" => %{
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
