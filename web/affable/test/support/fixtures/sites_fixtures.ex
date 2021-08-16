defmodule Affable.SitesFixtures do
  import Affable.AccountsFixtures

  alias Affable.Accounts.User
  alias Affable.Sites
  alias Affable.Sites.Site
  alias Affable.Sites.Publication

  def site_fixture() do
    site_fixture(user_fixture())
  end

  def unpersisted_site_fixture() do
    %Site{latest_publication: %Publication{}}
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

    site |> Sites.with_pages() |> Sites.with_items()
  end
end
