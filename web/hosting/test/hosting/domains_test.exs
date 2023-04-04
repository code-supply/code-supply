defmodule Hosting.DomainsTest do
  use Hosting.DataCase, async: true

  alias Hosting.Domains

  describe "domains" do
    alias Hosting.Domains.Domain
    alias Hosting.Sites.Site

    import Hosting.AccountsFixtures
    import Hosting.SitesFixtures

    @valid_attrs %{name: "somename.com"}
    @update_attrs %{name: "someupdatedname.com"}
    @invalid_attrs %{name: nil}

    setup do
      user = user_fixture()
      %{user: user, site: site_fixture(user)}
    end

    def domain_fixture(%Site{} = site, attrs \\ %{}) do
      {:ok, domain} =
        Domains.create_domain(
          site,
          attrs
          |> Enum.into(@valid_attrs)
        )

      domain
    end

    test "hosting suffix doesn't include 'hosting'" do
      assert String.starts_with?(
               Application.get_env(:hosting, HostingWeb.Endpoint)[:url][:host],
               "hosting."
             )

      refute String.contains?(Domains.hosting_suffix(), "hosting.")
    end

    test "can insert a domain into a list prior to first domain with same site" do
      assert [
               %Domain{site_id: 1, name: "site_a_initial"},
               %Domain{site_id: 2, name: "site_b_initial_1"},
               %Domain{site_id: 2, name: "site_b_initial_2"}
             ]
             |> Domains.list_insert(%Domain{site_id: 2, name: "site_b_new"})
             |> Enum.map(& &1.name) == [
               "site_a_initial",
               "site_b_new",
               "site_b_initial_1",
               "site_b_initial_2"
             ]
    end

    test "get_domain!/2 returns the domain with given id", %{site: site} do
      domain = domain_fixture(site)
      assert Domains.get_domain!(site, domain.id) == domain
    end

    test "get_domain!/2 fails if site doesn't own the domain", %{site: site} do
      domain = domain_fixture(site)

      assert_raise(Ecto.NoResultsError, fn ->
        Domains.get_domain!(site_fixture(user_fixture()), domain.id) == domain
      end)
    end

    test "create_domain/2 with valid data creates a domain", %{site: site} do
      assert {:ok, %Domain{} = domain} = Domains.create_domain(site, @valid_attrs)
      assert domain.name == "somename.com"
    end

    test "create_domain/2 with invalid data returns error changeset", %{site: site} do
      assert {:error, %Ecto.Changeset{}} = Domains.create_domain(site, @invalid_attrs)
    end

    test "create_domain/2 over existing name returns error changeset", %{
      site: %Site{domains: [domain]} = site
    } do
      assert {:error, %Ecto.Changeset{}} = Domains.create_domain(site, %{name: domain.name})
    end

    test "update_domain/2 with valid data updates the domain", %{site: site} do
      domain = domain_fixture(site)
      assert {:ok, %Domain{} = domain} = Domains.update_domain(domain, @update_attrs)
      assert domain.name == "someupdatedname.com"
    end

    test "update_domain/2 with invalid data returns error changeset", %{site: site} do
      domain = domain_fixture(site)
      assert {:error, %Ecto.Changeset{}} = Domains.update_domain(domain, @invalid_attrs)
      assert domain == Domains.get_domain!(site, domain.id)
    end

    test "can delete a domain", %{site: site, user: user} do
      domain = domain_fixture(site)
      assert %Domain{} = Domains.delete_domain!(user, "#{domain.id}")
      assert_raise Ecto.NoResultsError, fn -> Domains.get_domain!(site, domain.id) end
    end

    test "only site members can delete", %{user: user} do
      domain = domain_fixture(site_fixture())

      assert_raise(Ecto.NoResultsError, fn ->
        Domains.delete_domain!(user, "#{domain.id}")
      end)
    end

    test "cannot delete hosting domains", %{site: site, user: user} do
      domain = domain_fixture(site, %{name: "foobar.#{app_domain()}"})

      assert_raise(Ecto.NoResultsError, fn ->
        Domains.delete_domain!(user, "#{domain.id}")
      end)
    end

    test "change_domain/1 returns a domain changeset", %{site: site} do
      domain = domain_fixture(site)
      assert %Ecto.Changeset{} = Domains.change_domain(domain)
    end
  end
end
