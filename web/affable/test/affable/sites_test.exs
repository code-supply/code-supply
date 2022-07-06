defmodule Affable.SitesTest do
  use Affable.DataCase, async: true

  import Affable.{AccountsFixtures, SitesFixtures}
  import Affable.Sites.Raw

  alias Affable.Accounts.User
  alias Affable.Sites
  alias Affable.Sites.{Page, Site, SiteMember}
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
                 | pages: [%Page{path: "/contact"}]
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

    test "canonical URL appends custom port" do
      assert "//something.affable.app:4000/" ==
               %Site{domains: [%Domain{name: "something.affable.app"}]}
               |> Sites.canonical_url("4000")
    end

    test "canonical URL with a single domain uses that domain" do
      assert "//something.affable.app/" ==
               %Site{domains: [%Domain{name: "something.affable.app"}]}
               |> Sites.canonical_url(nil)
    end

    test "canonical URL with a custom domain is the custom domain" do
      assert "//my.domain.example.com/" ==
               %Site{
                 domains: [
                   %Domain{name: "something.affable.app"},
                   %Domain{name: "my.domain.example.com"}
                 ]
               }
               |> Sites.canonical_url(nil)
    end

    test "sites start with a publication" do
      %{
        sites: [
          %Site{
            name: name,
            publications: [publication]
          }
        ]
      } =
        user_fixture()
        |> Repo.preload(sites: [:publications])

      assert name == publication.data["name"]
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

      refute Sites.is_published?(%{published_again_site | pages: [%{page | title: "hi"}]})
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

      assert {:ok, updated_site} =
               Sites.update_site(site, %{
                 "name" => "some updated name"
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
