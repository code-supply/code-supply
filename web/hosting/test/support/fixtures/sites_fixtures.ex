defmodule Hosting.SitesFixtures do
  import Hosting.AccountsFixtures

  alias Hosting.Accounts.User
  alias Hosting.Sites
  alias Hosting.Sites.{Page, Site}

  def site_fixture do
    site_fixture(user_fixture())
  end

  def unpersisted_site_fixture do
    %Site{
      pages: [%Page{}]
    }
  end

  def site_fixture(%User{} = user, attrs \\ %{}) do
    {:ok, site} =
      Hosting.Sites.create_site(
        user,
        attrs
        |> Enum.into(%{
          name: "Top 10 Apples"
        })
      )

    site |> Sites.with_pages()
  end

  def page_fixture do
    user = unconfirmed_user_fixture()
    [site] = user.sites
    [page] = Sites.with_pages(site).pages
    {page, user}
  end
end
