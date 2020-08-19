defmodule Affable.Sites do
  import Ecto.Query, warn: false
  alias Affable.Repo
  alias Affable.Accounts.User
  alias Affable.Sites.{Site, SiteMember, Item}

  alias Ecto.Multi

  def get_site!(user, id) do
    items_q = items_query()

    from(s in Site,
      join: m in SiteMember,
      on: s.id == m.site_id,
      where:
        s.id == ^id and
          m.user_id == ^user.id,
      preload: [:domains, :members, items: ^items_q]
    )
    |> Repo.one!()
  end

  defp items_query do
    from i in Item, order_by: i.position
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
        description: "Yellow. Nothing like Red Delicious.",
        image_url: "https://upload.wikimedia.org/wikipedia/commons/0/09/Mele_golden.jpg",
        url: "https://commons.wikimedia.org/wiki/File:Mele_golden.jpg"
      },
      %Item{
        position: 2,
        name: "Gala",
        description: "Red. Offspring of Red D and Kidd's Orange.",
        image_url:
          "https://upload.wikimedia.org/wikipedia/commons/a/ab/2015-02-xx_Gala_%28apple%29.jpg",
        url: "https://commons.wikimedia.org/wiki/File:2015-02-xx_Gala_(apple).jpg"
      },
      %Item{
        position: 3,
        name: "Bramley",
        description: "Nice in a pie.",
        image_url:
          "https://upload.wikimedia.org/wikipedia/commons/5/52/Bramley%27s_Seedling_Apples.jpg",
        url: "https://commons.wikimedia.org/wiki/File:Bramley%27s_Seedling_Apples.jpg"
      },
      %Item{
        position: 4,
        name: "Red Prince",
        description: "Holland made an apple. It's kinda red.",
        image_url: "https://upload.wikimedia.org/wikipedia/commons/e/e8/Red_Prince_Aepfel.jpg",
        url: "https://commons.wikimedia.org/wiki/File:Red_Prince_Aepfel.jpg"
      },
      %Item{
        position: 5,
        name: "Greensleeves",
        description: "Parents are Golden D and James Grieve. That naughty James.",
        image_url:
          "https://upload.wikimedia.org/wikipedia/commons/d/d1/Greensleeves_on_tree%2C_National_Fruit_Collection_%28acc._1980-077%29.jpg",
        url:
          "https://commons.wikimedia.org/wiki/File:Greensleeves_on_tree,_National_Fruit_Collection_(acc._1980-077).jpg"
      },
      %Item{
        position: 6,
        name: "Red Delicious",
        description: "Dark Red. Popular in the states. Don't cook with it.",
        image_url: "https://upload.wikimedia.org/wikipedia/commons/6/6d/Red_Delicious_apples.jpg",
        url: "https://commons.wikimedia.org/wiki/File:Red_Delicious_apples.jpg"
      },
      %Item{
        position: 7,
        name: "Pink Lady",
        description: "From the 70's. Light red / pink. Tasty.",
        image_url:
          "https://upload.wikimedia.org/wikipedia/commons/b/b8/Pink_lady_apples%2C_Thulimbah%2C_Granite_Belt%2C_Queensland%2C_2015_02.jpg",
        url:
          "https://commons.wikimedia.org/wiki/File:Pink_lady_apples,_Thulimbah,_Granite_Belt,_Queensland,_2015_02.jpg"
      },
      %Item{
        position: 8,
        name: "Discovery",
        description: "Sweet flavour. English.",
        image_url: "https://upload.wikimedia.org/wikipedia/commons/a/a3/Discovery_apples.jpg",
        url: "https://commons.wikimedia.org/wiki/File:Discovery_apples.jpg"
      },
      %Item{
        position: 9,
        name: "Braeburn",
        description: "Common in the UK supermarkets. Pretty good!",
        image_url: "https://upload.wikimedia.org/wikipedia/commons/f/fc/Braeburn2008.jpg",
        url: "https://commons.wikimedia.org/wiki/File:Braeburn2008.jpg"
      },
      %Item{
        position: 10,
        name: "Cox's Orange Pippin",
        description: "Kind of a big deal in the UK.",
        image_url: "https://upload.wikimedia.org/wikipedia/commons/e/ed/Cox_orange_renette2.JPG",
        url: "https://commons.wikimedia.org/wiki/File:Cox_orange_renette2.JPG"
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

  def promote_item(site, item_id) do
    move_item(site, item_id, fn pos -> pos - 1 end)
  end

  def demote_item(site, item_id) do
    move_item(site, item_id, fn pos -> pos + 1 end)
  end

  defp move_item(site, item_id, f) do
    {item_id, ""} = Integer.parse(item_id)

    demotee =
      site.items
      |> Enum.find(fn item -> item.id == item_id end)

    promotee =
      site.items
      |> Enum.find(fn item -> item.position == f.(demotee.position) end)

    case promotee do
      nil ->
        {:ok, site}

      _ ->
        Multi.new()
        |> Multi.update(
          :move,
          Item.changeset(demotee, %{position: -demotee.position})
        )
        |> Multi.update(
          :promote,
          Item.changeset(promotee, %{position: promotee.position - f.(0)})
        )
        |> Multi.update(
          :demote,
          Item.changeset(demotee, %{position: promotee.position})
        )
        |> Repo.transaction()

        {
          :ok,
          Repo.get!(Site, site.id)
          |> Repo.preload(:domains)
          |> Repo.preload(:members)
          |> Repo.preload(items: items_query())
        }
    end
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
