defmodule Affable.SitesFixtures do
  import Affable.AccountsFixtures

  alias Affable.Accounts.User

  def site_fixture() do
    site_fixture(user_fixture())
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

    site |> Affable.Repo.preload(items: [attributes: :definition])
  end
end
