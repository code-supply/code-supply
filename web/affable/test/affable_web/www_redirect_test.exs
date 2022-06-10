defmodule AffableWeb.WwwRedirectTest do
  use AffableWeb.ConnCase, async: true

  import Affable.SitesFixtures

  alias Affable.Domains
  alias AffableWeb.Plugs.WwwRedirect

  test "redirected when stored domain has www, but requested without" do
    Domains.create_domain(site_fixture(), %{name: "www.poop.com"})

    assert redirected_to(
             build_conn(:get, "https://poop.com/something")
             |> WwwRedirect.call(%{}),
             :moved_permanently
           ) =~ "https://www.poop.com/something"
  end

  test "redirect when stored domain has no www, but requested with" do
    Domains.create_domain(site_fixture(), %{name: "poop.com"})

    assert redirected_to(
             build_conn(:get, "https://www.poop.com/something")
             |> WwwRedirect.call(%{}),
             :moved_permanently
           ) =~ "https://poop.com/something"
  end

  test "no modification when stored domain matches" do
    Domains.create_domain(site_fixture(), %{name: "poop.com"})
    conn = build_conn(:get, "https://poop.com/something")

    assert WwwRedirect.call(conn, %{}) == conn
  end

  test "no modification when domain not found" do
    conn = build_conn(:get, "https://poop.com/something")

    assert WwwRedirect.call(conn, %{}) == conn
  end
end
