defmodule Affable.DomainsTest do
  use Affable.DataCase, async: true
  import Hammox

  alias Affable.Domains

  describe "domains" do
    alias Affable.Domains.Domain
    alias Affable.Sites.Site

    import Affable.AccountsFixtures
    import Affable.SitesFixtures

    @valid_attrs %{name: "somename.com"}
    @update_attrs %{name: "someupdatedname.com"}
    @invalid_attrs %{name: nil}

    setup do
      %{site: site_fixture(user_fixture())}
    end

    setup :verify_on_exit!

    def domain_fixture(%Site{} = site, attrs \\ %{}) do
      {:ok, domain} =
        Domains.create_domain(
          site,
          attrs
          |> Enum.into(@valid_attrs)
        )

      domain
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

    test "delete_domain/1 deletes the domain", %{site: site} do
      domain = domain_fixture(site)
      assert {:ok, %Domain{}} = Domains.delete_domain(domain)
      assert_raise Ecto.NoResultsError, fn -> Domains.get_domain!(site, domain.id) end
    end

    test "change_domain/1 returns a domain changeset", %{site: site} do
      domain = domain_fixture(site)
      assert %Ecto.Changeset{} = Domains.change_domain(domain)
    end
  end
end
