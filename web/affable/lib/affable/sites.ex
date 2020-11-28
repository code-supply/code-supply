defmodule Affable.Sites do
  @behaviour Affable.SiteClusterIO

  import Ecto.Query, warn: false
  alias Affable.Repo
  alias Affable.Accounts.User

  alias Affable.Sites.{
    Payload,
    Publication,
    Site,
    SiteMember,
    Item,
    AttributeDefinition,
    Attribute,
    Raw
  }

  alias Affable.Domains.Domain

  alias Ecto.Multi

  def status(site) do
    if site.made_available_at do
      :available
    else
      :pending
    end
  end

  def publish(site) do
    Ecto.build_assoc(site, :publications, %{data: Raw.raw(site)})
    |> Repo.insert()

    {:ok, site}
  end

  def is_published?(site) do
    case latest_publication(site) do
      nil ->
        false

      latest ->
        latest.data == Raw.raw(site)
    end
  end

  def latest_publication(site) do
    from(p in Publication,
      where: p.site_id == ^site.id,
      order_by: [desc: p.id],
      limit: 1
    )
    |> Repo.one()
  end

  def canonical_url(%Site{domains: [%Domain{name: name}]}) do
    "//#{name}/"
  end

  def canonical_url(%Site{domains: domains}) do
    domain =
      domains
      |> Enum.find(fn d ->
        !(d.name |> String.ends_with?(".affable.app"))
      end)

    "//#{domain.name}/"
  end

  def get_site!(user, id) do
    site_query(id)
    |> join(:inner, [s], m in SiteMember, on: s.id == m.site_id)
    |> where([s, m], m.user_id == ^user.id)
    |> Repo.one!()
  end

  def get_site!(id) do
    site_query(id)
    |> Repo.one!()
  end

  @impl true
  def get_raw_site(id) do
    case base_site_query(id) |> Repo.one() do
      %Site{} = site ->
        {:ok,
         %Payload{
           preview: Raw.raw(site),
           published: latest_publication(site).data
         }
         |> Map.from_struct()}

      nil ->
        {:error, :not_found}
    end
  end

  defp base_site_query(id) do
    items_q = items_query()
    definitions_q = definitions_query()

    from(s in Site,
      where: s.id == ^id,
      preload: [items: ^items_q, attribute_definitions: ^definitions_q]
    )
  end

  defp site_query(id) do
    base_site_query(id)
    |> preload([], [:domains, :members])
  end

  @impl true
  def set_available(id, at) do
    site =
      from(s in Site, where: s.id == ^id)
      |> Repo.one()

    if site.made_available_at do
      {:ok, site}
    else
      site
      |> Site.change_made_available_at(at)
      |> Repo.update()
    end
  end

  defp items_query do
    attributes_q = from(a in Attribute, order_by: [desc: a.definition_id])
    from(i in Item, order_by: i.position, preload: ^[attributes: {attributes_q, [:definition]}])
  end

  defp definitions_query do
    from(i in AttributeDefinition, order_by: [desc: i.id])
  end

  def unshared(user) do
    user = user |> Repo.preload(sites: :users)
    user_id = user.id

    for %Site{users: [%User{id: ^user_id}]} = site <- user.sites do
      site
    end
  end

  def create_site_multi(user, attrs) do
    Multi.new()
    |> Multi.insert(
      :site,
      %Site{}
      |> Site.changeset(attrs)
      |> Site.change_internal_name("pending")
      |> Ecto.Changeset.put_assoc(:members, [Ecto.build_assoc(user, :site_members)])
      |> Ecto.Changeset.put_assoc(:items, default_items())
    )
    |> Multi.update(:site_with_internal_name, fn %{site: site} ->
      site
      |> Site.change_internal_name(Affable.ID.site_name_from_id(site.id))
    end)
    |> Multi.insert(
      :domain,
      fn %{site_with_internal_name: site} ->
        Ecto.build_assoc(site, :domains, %{name: "#{site.internal_name}.affable.app"})
      end
    )
    |> Multi.merge(fn %{site: site} ->
      add_attribute_definition_multi(site)
    end)
    |> Multi.insert(
      :publish,
      fn %{site: site} ->
        Ecto.build_assoc(site, :publications, %{
          data: Raw.raw(site |> Repo.preload(items: [attributes: :definition]))
        })
      end
    )
  end

  def create_site(%User{} = user, attrs \\ %{}) do
    case create_site_multi(user, attrs)
         |> Repo.transaction() do
      {:ok, %{site_with_internal_name: site}} ->
        {:ok, site |> Repo.preload([:domains, [items: :attributes]])}

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
    case site
         |> Site.changeset(attrs)
         |> Repo.update() do
      {:ok, site} ->
        {:ok, site |> Repo.preload([items: items_query()], force: true)}

      otherwise ->
        otherwise
    end
  end

  def delete_site(%Site{} = site) do
    Repo.delete(site)
  end

  def change_site(%Site{} = site, attrs \\ %{}) do
    Site.changeset(site, attrs)
  end

  def promote_item(user, site, item_id) do
    if site |> has_user?(user) do
      move_item(site, item_id, &(&1 - 1))
    else
      {:error, :unauthorized}
    end
  end

  def demote_item(user, site, item_id) do
    if site |> has_user?(user) do
      move_item(site, item_id, &(&1 + 1))
    else
      {:error, :unauthorized}
    end
  end

  defp move_item(site, item_id, f) do
    {item_id, ""} = Integer.parse(item_id)

    demotee_idx =
      site.items
      |> Enum.find_index(&(&1.id == item_id))

    demotee = site.items |> Enum.at(demotee_idx)

    promotee_idx =
      site.items
      |> Enum.find_index(&(&1.position == f.(demotee.position)))

    if promotee_idx do
      promotee = site.items |> Enum.at(promotee_idx)

      {:ok, %{promote: promoted_item, demote: demoted_item}} =
        move_item_multi(demotee, promotee, f)
        |> Repo.transaction()

      {
        :ok,
        site
        |> Map.update!(:items, fn items ->
          items
          |> List.replace_at(promotee_idx, promoted_item)
          |> List.replace_at(demotee_idx, demoted_item)
          |> Enum.sort_by(& &1.position)
        end)
        |> Repo.preload(items: [attributes: :definition])
        |> broadcast()
      }
    else
      {:ok, site}
    end
  end

  defp move_item_multi(demotee, promotee, f) do
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
  end

  alias Affable.Sites.AttributeDefinition

  defp add_attribute_definition_multi(site) do
    multi =
      Multi.new()
      |> Multi.insert(
        :definition,
        site
        |> Ecto.build_assoc(:attribute_definitions)
        |> AttributeDefinition.changeset(%{name: "Price", type: "dollar"})
      )

    site.items
    |> Enum.reduce(multi, fn item, multi ->
      multi
      |> Multi.insert("item#{item.id}", fn %{definition: definition} ->
        Ecto.build_assoc(item, :attributes, %{definition_id: definition.id, value: "1.23"})
      end)
    end)
  end

  def add_attribute_definition(user, site) do
    if site |> has_user?(user) do
      {:ok, _} =
        add_attribute_definition_multi(site)
        |> Repo.transaction()

      {:ok, get_site!(site.id)}
    else
      {:error, :unauthorized}
    end
  end

  defp has_user?(site, user) do
    Repo.exists?(from(SiteMember, where: [user_id: ^user.id, site_id: ^site.id]))
  end

  def delete_attribute_definition(%User{} = user, definition_id) do
    case from(ad in AttributeDefinition,
           where: ad.id == ^definition_id,
           join: s in Site,
           on: s.id == ad.site_id,
           join: sm in SiteMember,
           on: sm.site_id == s.id,
           where: sm.user_id == ^user.id
         )
         |> Repo.delete_all() do
      {0, _} ->
        {:error, "Couldn't delete"}

      _ ->
        {:ok, ""}
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

  def create_item(site, attrs \\ %{}) do
    site
    |> Ecto.build_assoc(:items)
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def prepend_item(user, site) do
    if site |> has_user?(user) do
      {:ok, {:ok, item}} =
        Repo.transaction(fn ->
          for item <- site.items |> Enum.reverse() do
            update_item(
              item,
              %{position: item.position + 1}
            )
          end

          create_item(site, %{
            name: "New item",
            position: 1,
            attributes:
              for definition <- site.attribute_definitions do
                %{definition_id: definition.id, value: "1.23"}
              end
          })
        end)

      {:ok, item |> Repo.preload(attributes: :definition)}
    else
      {:error, :unauthorized}
    end
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

  def delete_item(%Site{} = site, item_id) do
    delete_position =
      site.items
      |> Enum.find_value(fn item ->
        if "#{item.id}" == "#{item_id}" do
          item.position
        else
          false
        end
      end)

    site.items
    |> Enum.reduce(Ecto.Multi.new(), fn item, multi ->
      cond do
        "#{item.id}" == "#{item_id}" ->
          Multi.delete(multi, :delete, item)

        item.position > delete_position ->
          Multi.update(
            multi,
            "reposition-#{item.id}",
            Item.changeset(item, %{position: item.position - 1})
          )

        true ->
          multi
      end
    end)
    |> Repo.transaction()

    {:ok, get_site!(site.id)}
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

  def broadcast(site) do
    :ok =
      broadcaster().broadcast(%Payload{
        preview: Raw.raw(site),
        published: latest_publication(site).data
      })

    site
  end

  defp broadcaster() do
    Application.get_env(:affable, :broadcaster)
  end
end
