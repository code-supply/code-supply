defmodule Affable.SitesFixtures do
  import Affable.AccountsFixtures

  alias Affable.Accounts.User
  alias Affable.Sites
  alias Affable.Sites.{Page, Site}
  alias Affable.Sites.Publication

  def site_fixture() do
    site_fixture(user_fixture())
  end

  def unpersisted_site_fixture() do
    %Site{
      latest_publication: %Publication{},
      layout: nil,
      site_logo: nil,
      pages: [%Page{header_image: nil}]
    }
  end

  def site_fixture(%User{} = user, attrs \\ %{}) do
    {:ok, site} =
      Affable.Sites.create_site(
        user,
        attrs
        |> Enum.into(%{
          name: "Top 10 Apples"
        })
      )

    site |> Sites.with_pages()
  end

  def page_fixture() do
    user = unconfirmed_user_fixture()
    [site] = user.sites
    [page] = Sites.with_pages(site).pages
    {page, user}
  end
end
