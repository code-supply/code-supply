defmodule Affable.SitesTest do
  use Affable.DataCase, async: true

  import Affable.{AccountsFixtures, SitesFixtures}
  import Affable.Sites.Raw
  import Access, only: [at: 1]

  alias Affable.Accounts.User
  alias Affable.Assets
  alias Affable.Assets.Asset
  alias Affable.Layouts.Layout
  alias Affable.Sites
  alias Affable.Sites.{Page, Section, Site, SiteMember}
  alias Affable.Domains.Domain

  describe "pages" do
    test "adding a page requires correct user, broadcasts result" do
      user = user_fixture()
      site = site_fixture(user)

      assert {:error, :unauthorized} = Sites.add_page(site, wrong_user())

      assert {:ok, %Page{title: "Untitled page"}} = Sites.add_page(site, user)

      assert [%Page{} | [%Page{title: "Untitled page"}]] = Sites.get_site!(site.id).pages
    end

    test "updating a page broadcasts the result" do
      user = user_fixture()
      site = site_fixture(user)
      [page] = site.pages

      {:ok, page} = Sites.update_page(page, %{title: "my new title"}, user)

      assert "my new title" == page.title
    end

    test "can add multiple sections and delete them" do
      {page, user} = page_fixture()

      {:ok, page} = Sites.add_page_section(page, user)

      {:ok, page} = Sites.add_page_section(page, user)

      assert ["untitled-section", "untitled-section-2"] == Enum.map(page.sections, & &1.name)

      [first_section, _] = page.sections
      Sites.delete_page_section(first_section.id, user)

      %Site{pages: [%Page{sections: [section]}]} = Sites.get_site!(page.site_id)
      assert section.name == "untitled-section-2"
    end

    test "updating a page with incorrect user is not allowed" do
      site = site_fixture()
      [%Page{title: old_title} = page] = site.pages

      assert {:error, :unauthorized} =
               Sites.update_page(page, %{title: "my new title"}, wrong_user())

      assert [%Page{title: ^old_title}] = Sites.get_site!(site.id).pages
    end

    test "deleting a page broadcasts the result" do
      user = user_fixture()
      %Site{pages: [page]} = site_fixture(user)
      Sites.delete_page(page.id, user)
    end

    test "default path is / when available" do
      assert "/" == Sites.default_path(["/other", "/"])
    end

    test "default path is first page when / not available" do
      assert "/other" == Sites.default_path(["/other", "/yetanother"])
    end

    test "default path is / when there are no more pages" do
      assert "/" == Sites.default_path([])
    end

    test "raw representation includes path" do
      assert %{"pages" => [%{"path" => "/contact"}]} =
               %{
                 unpersisted_site_fixture()
                 | pages: [%Page{path: "/contact", header_image: nil, sections: []}]
               }
               |> raw()
    end

    test "raw representation includes layout, sections and grid stuff" do
      assert %{
               "layout" => %{
                 "grid_template_areas" => "head head\nnav main\nfooter footer",
                 "grid_template_rows" => "50px 1fr 30px",
                 "grid_template_columns" => "150px 1fr",
                 "sections" => [
                   %{},
                   %{},
                   %{},
                   %{}
                 ]
               },
               "pages" => [
                 %{
                   "grid_template_areas" => "head head\nnav main\nnav foot",
                   "grid_template_rows" => "50px 1fr 30px",
                   "grid_template_columns" => "150px 1fr",
                   "sections" => [
                     %{
                       "name" => "my-section",
                       "element" => "header",
                       "background_colour" => "FF0000",
                       "image_url" =>
                         "https://images.affable.app/nosignature/fill/567/341/ce/0/plain/http://example.com/foo.jpg",
                       "image_name" => "Image of a Foo"
                     }
                   ]
                 }
               ]
             } =
               %Site{
                 unpersisted_site_fixture()
                 | layout: %Layout{
                     grid_template_areas: "head head\nnav main\nfooter footer",
                     grid_template_rows: "50px 1fr 30px",
                     grid_template_columns: "150px 1fr",
                     sections: [
                       %Section{
                         name: "header",
                         element: "header",
                         background_colour: "FF0000",
                         image: nil
                       },
                       %Section{
                         name: "nav",
                         element: "nav",
                         background_colour: "FF0000",
                         image: nil
                       },
                       %Section{
                         name: "main",
                         element: "main",
                         background_colour: "FF0000",
                         image: nil
                       },
                       %Section{
                         name: "footer",
                         element: "footer",
                         background_colour: "FF0000",
                         image: nil
                       }
                     ]
                   },
                   pages: [
                     %Page{
                       path: "/contact",
                       header_image: nil,
                       grid_template_areas: "head head\nnav main\nnav foot",
                       grid_template_rows: "50px 1fr 30px",
                       grid_template_columns: "150px 1fr",
                       sections: [
                         %Section{
                           name: "my-section",
                           element: "header",
                           background_colour: "FF0000",
                           image: %Asset{
                             url: "http://example.com/foo.jpg",
                             name: "Image of a Foo"
                           }
                         }
                       ]
                     }
                   ]
               }
               |> raw()
    end
  end

  describe "sites" do
    alias Affable.Sites.Site

    @invalid_attrs %{name: nil}

    defp user_and_site() do
      %User{sites: [site]} = user = unconfirmed_user_fixture()

      {
        user,
        site |> Sites.with_pages()
      }
    end

    test "preview URL chooses affable domain" do
      assert "//something.affable.app/preview" ==
               %Site{
                 domains: [
                   %Domain{name: "something.affable.app"},
                   %Domain{name: "my.domain.example.com"}
                 ]
               }
               |> Sites.preview_url()
    end

    test "preview URL chooses only domain if there are no affable ones" do
      assert "//my.domain.example.com/preview" ==
               %Site{
                 domains: [
                   %Domain{name: "my.domain.example.com"}
                 ]
               }
               |> Sites.preview_url()
    end

    test "preview URL chooses last domain if there are multiple, and none are affable domains" do
      assert "//ohhi/preview" ==
               %Site{
                 domains: [
                   %Domain{name: "my.domain.example.com"},
                   %Domain{name: "ohhi"}
                 ]
               }
               |> Sites.preview_url()
    end

    test "canonical URL with a single domain uses that domain" do
      assert "//something.affable.app/" ==
               %Site{domains: [%Domain{name: "something.affable.app"}]}
               |> Sites.canonical_url()
    end

    test "canonical URL with a custom domain is the custom domain" do
      assert "//my.domain.example.com/" ==
               %Site{
                 domains: [
                   %Domain{name: "something.affable.app"},
                   %Domain{name: "my.domain.example.com"}
                 ]
               }
               |> Sites.canonical_url()
    end

    test "sites start with a publication" do
      %{
        sites: [
          %Site{
            pages: [%Page{header_image: %Asset{url: header_image_url}}],
            publications: [publication]
          }
        ]
      } =
        user_fixture()
        |> Repo.preload(sites: [pages: [:header_image], publications: []])

      assert Assets.to_imgproxy_url(header_image_url,
               width: 567,
               height: 341,
               resizing_type: "fill"
             ) == get_in(publication.data, ["pages", at(0), "header_image_url"])
    end

    test "site is published when latest publication is same as current raw representation" do
      site = site_fixture()
      Repo.delete(site.latest_publication)

      refute Sites.is_published?(site)

      {:ok, published_site} = Sites.publish(site)

      assert Sites.is_published?(published_site)

      {:ok, published_again_site} = Sites.publish(site)

      assert Sites.is_published?(published_again_site)

      %{pages: [page]} = published_again_site

      refute Sites.is_published?(%{published_again_site | pages: [%{page | header_text: "hi"}]})
    end

    test "raw representation copes with images being missing" do
      expected_logo_url = Assets.to_imgproxy_url("foo", width: 600, height: 176)

      expected_header_image_url =
        Assets.to_imgproxy_url("foo", width: 567, height: 341, resizing_type: "fill")

      assert %{
               "pages" => [%{"header_image_url" => nil}],
               "site_logo_url" => ^expected_logo_url
             } =
               raw(%Site{
                 layout: nil,
                 site_logo: %Asset{url: "foo"},
                 pages: [%Page{header_image: nil, sections: []}]
               })

      assert %{
               "pages" => [%{"header_image_url" => ^expected_header_image_url}],
               "site_logo_url" => nil
             } =
               raw(%Site{
                 layout: nil,
                 pages: [%Page{header_image: %Asset{url: "foo"}, sections: []}],
                 site_logo: nil
               })
    end

    test "get_site!/1 preloads latest publication" do
      site = site_fixture()
      assert Sites.get_site!(site.id).latest_publication.data
    end

    test "get_site!/2 returns the site with given user id and id" do
      user = user_fixture()
      site = site_fixture(user)
      assert Sites.get_site!(user, site.id).id == site.id
    end

    test "get_site!/2 fails if user is incorrect" do
      site = site_fixture()

      assert_raise Ecto.NoResultsError, fn ->
        Sites.get_site!(wrong_user(), site.id)
      end
    end

    test "new sites have batteries-included defaults" do
      user = user_fixture()
      site = site_fixture(user, %{name: "some name !@#!@#$@#%#$"})

      [%SiteMember{user_id: received_user_id}] = site.members
      [%Domain{name: domain_name}] = site.domains

      assert site.name == "some name !@#!@#$@#%#$"
      assert site.internal_name =~ ~r/site[a-z0-9]+/
      assert site.internal_hostname =~ ~r/^app\.site[a-z0-9]+$/
      assert domain_name == "#{site.internal_name}.affable.app"
      assert received_user_id == user.id

      assert Sites.is_published?(site)
    end

    test "create_site/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sites.create_site(user_fixture(), @invalid_attrs)
    end

    test "update_site/2 with valid data updates the site" do
      {_, site} = user_and_site()

      %Site{pages: [%Page{header_image: %Asset{id: header_image_id}}]} =
        site |> Repo.preload(pages: [:header_image])

      assert {:ok, updated_site} =
               Sites.update_site(site, %{
                 "name" => "some updated name",
                 "site_logo_id" => header_image_id
               })

      assert updated_site.name == "some updated name"
    end

    test "update_site/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Sites.update_site(site_fixture(), @invalid_attrs)
    end

    test "delete_site/1 deletes the site" do
      %User{sites: [site]} = user = user_fixture()
      assert {:ok, %Site{}} = Sites.delete_site(site)
      assert_raise Ecto.NoResultsError, fn -> Sites.get_site!(user, site.id) end
    end

    test "change_site/1 returns a site changeset" do
      site = site_fixture()
      assert %Ecto.Changeset{} = Sites.change_site(site)
    end
  end
end
