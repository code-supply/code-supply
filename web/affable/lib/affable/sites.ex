defmodule Affable.Sites do
  import Ecto.Query, warn: false
  alias Affable.Repo
  alias Affable.Accounts.User
  alias Affable.Sites.{Site, SiteMember, Item}

  alias Ecto.Multi

  def get_site!(user, id) do
    from(s in Site,
      join: m in SiteMember,
      on: s.id == m.site_id,
      where:
        s.id == ^id and
          m.user_id == ^user.id,
      preload: [:domains, :members, :items]
    )
    |> Repo.one!()
  end

  def create_site(%User{} = user, attrs \\ %{}) do
    case Multi.new()
         |> Multi.insert(
           :site,
           %Site{}
           |> Site.changeset(attrs)
           |> Ecto.Changeset.put_assoc(:members, [Ecto.build_assoc(user, :site_members)])
           |> Ecto.Changeset.put_assoc(:items, default_items())
         )
         |> Multi.insert(
           :domain,
           fn %{site: site} ->
             Ecto.build_assoc(site, :domains, %{name: generate_domain_name(site.id)})
           end
         )
         |> Repo.transaction() do
      {:ok, %{site: site}} ->
        {:ok, site |> Repo.preload(:domains) |> Repo.preload(:items)}

      {:error, :site, site, %{} = _domain} ->
        {:error, site}
    end
  end

  defp default_items do
    [
      %Item{
        position: 1,
        name: "Golden Delicious",
        description: "Yellow. Nothing like Red Delicious."
      },
      %Item{
        position: 2,
        name: "Gala",
        description: "Red. Offspring of Red D and Kidd's Orange."
      },
      %Item{
        position: 3,
        name: "Bramley",
        description: "Nice in a pie."
      },
      %Item{
        position: 4,
        name: "Red Prince",
        description: "Holland made an apple. It's kinda red."
      },
      %Item{
        position: 5,
        name: "Greensleeves",
        description: "Parents are Golden D and James Grieve. That naughty James."
      },
      %Item{
        position: 6,
        name: "Red Delicious",
        description: "Dark Red. Popular in the states. Don't cook with it."
      },
      %Item{
        position: 7,
        name: "Pink Lady",
        description: "From the 70's. Light red / pink. Tasty."
      },
      %Item{
        position: 8,
        name: "Discovery",
        description: "Sweet flavour. English."
      },
      %Item{
        position: 9,
        name: "Crispin",
        description: "Japanese, offshoot of Golden D and Indo."
      },
      %Item{
        position: 10,
        name: "Gavin",
        description: "Is this one a joke or what?"
      }
    ]
    |> Enum.map(&Item.changeset(&1, %{}))
  end

  def update_site(%Site{} = site, attrs) do
    site
    |> Site.changeset(attrs)
    |> Repo.update()
  end

  def delete_site(%Site{} = site) do
    Repo.delete(site)
  end

  def change_site(%Site{} = site, attrs \\ %{}) do
    Site.changeset(site, attrs)
  end

  def generate_domain_name(number) do
    "site#{Affable.ID.encode(number)}.affable.app"
  end

  alias Affable.Sites.Item

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(Item)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end
end
