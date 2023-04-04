defmodule Hosting.SitesTest do
  use Hosting.DataCase, async: true

  import Hosting.{AccountsFixtures, SitesFixtures}

  alias Hosting.Accounts.User
  alias Hosting.Sites
  alias Hosting.Sites.{Page, Site, SiteMember}
  alias Hosting.Domains.Domain

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
  end

  describe "sites" do
    alias Hosting.Sites.Site

    @invalid_attrs %{name: nil}

    defp user_and_site() do
      %User{sites: [site]} = user = unconfirmed_user_fixture()

      {
        user,
        site |> Sites.with_pages()
      }
    end

    test "preview URL chooses hosting domain" do
      assert "//something.#{app_domain()}/?preview" ==
               %Site{
                 domains: [
                   %Domain{name: "something.#{app_domain()}"},
                   %Domain{name: "my.domain.example.com"}
                 ]
               }
               |> Sites.preview_url()
    end

    test "preview URL chooses only domain if there are no hosting ones" do
      assert "//my.domain.example.com:4000/?preview" ==
               %Site{
                 domains: [
                   %Domain{name: "my.domain.example.com"}
                 ]
               }
               |> Sites.preview_url(4000)
    end

    test "preview URL chooses last domain if there are multiple, and none are hosting domains" do
      assert "//ohhi/?preview" ==
               %Site{
                 domains: [
                   %Domain{name: "my.domain.example.com"},
                   %Domain{name: "ohhi"}
                 ]
               }
               |> Sites.preview_url()
    end

    test "canonical URL appends custom port" do
      assert "//something.#{app_domain()}:4000/" ==
               %Site{domains: [%Domain{name: "something.#{app_domain()}"}]}
               |> Sites.canonical_url("4000")
    end

    test "canonical URL with a single domain uses that domain" do
      assert "//something.code.supply/" ==
               %Site{domains: [%Domain{name: "something.code.supply"}]}
               |> Sites.canonical_url(nil)
    end

    test "canonical URL with a custom domain is the custom domain" do
      assert "//my.domain.example.com/" ==
               %Site{
                 domains: [
                   %Domain{name: "something.#{app_domain()}"},
                   %Domain{name: "my.domain.example.com"}
                 ]
               }
               |> Sites.canonical_url(nil)
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
      assert domain_name == "#{site.internal_name}.code.test"
      assert received_user_id == user.id
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
