defmodule Affable.Sites do
  @behaviour Affable.SiteClusterIO

  import Ecto.Query, warn: false

  alias Affable.Sites.Raw
  alias Affable.Repo
  alias Affable.Accounts.User
  alias Affable.Assets
  alias Affable.Assets.Asset
  alias Affable.Domains

  alias Affable.Sites.{
    Publication,
    Site,
    SiteMember,
    Item,
    AttributeDefinition,
    Attribute
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
    site = site |> preload_base_assets()

    site
    |> Ecto.build_assoc(:publications, %{data: raw(site)})
    |> Repo.insert()

    {
      :ok,
      site
      |> broadcast()
    }
  end

  def is_published?(%Site{id: id} = site) do
    latest_publication =
      from(p in Publication, where: [site_id: ^id], order_by: [desc: p.id], limit: 1)
      |> Repo.one!()

    case latest_publication do
      nil ->
        false

      latest ->
        latest.data ==
          raw(site)
    end
  end

  defp raw(%Site{} = site) do
    site
    |> with_items()
    |> Raw.raw()
  end

  def canonical_url(%Site{domains: [%Domain{name: name}]}) do
    "//#{name}/"
  end

  def canonical_url(%Site{domains: domains}) do
    domain = Enum.find(domains, &(!Domains.affable_domain?(&1)))

    "//#{domain.name}/"
  end

  def preview_url(%Site{domains: [%Domain{name: name}]}) do
    "//#{name}/preview"
  end

  def preview_url(%Site{domains: domains}) do
    domain = Enum.find(domains, &Domains.affable_domain?(&1))

    "//#{domain.name}/preview"
  end

  def get_site!(user, id) do
    site_query(id)
    |> join(:inner, [s], m in SiteMember, on: s.id == m.site_id)
    |> where([s, m], m.user_id == ^user.id)
    |> Repo.one!()
    |> with_items()
  end

  @impl true
  def get_site!(%Site{id: id}) do
    get_site!(id)
  end

  @impl true
  def get_site!(id) do
    site_query(id)
    |> Repo.one!()
    |> with_items()
    |> preload_latest_publication()
  end

  defp site_query(id) do
    items_q = items_query()
    definitions_q = definitions_query()

    from(s in Site,
      where: s.id == ^id,
      preload: [
        assets: [],
        domains: [],
        header_image: [],
        members: [],
        site_logo: [],
        items: ^items_q,
        attribute_definitions: ^definitions_q
      ]
    )
  end

  def reload_assets(%Site{} = site) do
    Repo.preload(site, [assets: Assets.default_query()], force: true)
  end

  defp preload_base_assets(site, opts \\ []) do
    Repo.preload(site, [:header_image, :site_logo], opts)
  end

  defp preload_latest_publication(site) do
    site
    |> preload_base_assets
    |> Repo.preload(latest_publication: from(p in Publication, order_by: [desc: p.id]))
  end

  @impl true
  def set_available(id, at) do
    site =
      from(s in Site, where: s.id == ^id)
      |> Repo.one()
      |> preload_latest_publication()
      |> Repo.preload(:domains)

    if site.made_available_at do
      {:ok, site}
    else
      site
      |> Site.change_made_available_at(at)
      |> Repo.update()
    end
  end

  def with_items(site, attrs \\ []) do
    site
    |> Repo.preload(
      [
        items: items_query(),
        attribute_definitions: definitions_query()
      ],
      attrs
    )
    |> Repo.preload(items: [image: [], attributes: :definition])
  end

  defp items_query do
    attributes_q = from(a in Attribute, order_by: [desc: a.definition_id])

    from(i in Item,
      order_by: i.position,
      preload: ^[image: [], attributes: attributes_q]
    )
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

  def create_bare_site(%User{} = user, attrs \\ %{}) do
    create_bare_site_multi(user, attrs)
    |> Repo.transaction()
    |> handle_create_site_multi(:site_with_internal_name)
  end

  def create_site(%User{} = user, attrs \\ %{}) do
    create_site_multi(user, attrs)
    |> Repo.transaction()
    |> handle_create_site_multi(:site_with_default_assets)
  end

  def create_bare_site_multi(user, attrs) do
    Multi.new()
    |> site_with_name_multi(user, attrs)
    |> Multi.insert(:publish, &build_publication(&1.site))
  end

  def create_site_multi(user, attrs) do
    Multi.new()
    |> site_with_name_multi(user, attrs)
    |> default_assets_multi()
    |> Multi.merge(fn %{site: site} ->
      add_attribute_definition_multi(site)
    end)
    |> default_items_multi()
    |> Multi.insert(:publish, &build_publication(&1.site_with_default_assets))
  end

  defp handle_create_site_multi(result, site_multi_key) do
    case result do
      {:ok, multis} ->
        {
          :ok,
          multis[site_multi_key]
          |> with_items()
          |> Repo.preload(:domains)
          |> preload_latest_publication()
        }

      {:error, :site, site, %{} = _domain} ->
        {:error, site}
    end
  end

  defp default_items_multi(%Multi{} = multi) do
    Enum.reduce(default_items(), multi, fn {identifier, item}, multi ->
      Multi.insert(
        multi,
        "item#{item.position}",
        fn %{site: site, definition: definition} = previous_multis ->
          %{
            item
            | site_id: site.id,
              image_id: previous_multis[identifier].id,
              attributes: [%Attribute{value: "1.23", definition_id: definition.id}]
          }
        end
      )
    end)
  end

  defp build_publication(site) do
    Ecto.build_assoc(site, :publications, %{
      data:
        raw(
          site
          |> with_items()
          |> Repo.preload(site_logo: [], header_image: [])
        )
    })
  end

  defp site_with_name_multi(%Multi{} = multi, user, attrs) do
    multi
    |> Multi.insert(
      :site,
      %Site{cta_text: "Go", cta_background_colour: "059669", cta_text_colour: "FFFFFF"}
      |> Site.changeset(attrs)
      |> Site.change_internal_name("pending")
      |> Ecto.Changeset.put_assoc(:members, [Ecto.build_assoc(user, :site_members)])
    )
    |> Multi.update(:site_with_internal_name, fn %{site: site} ->
      site
      |> Site.change_internal_name(Affable.ID.site_name_from_id(site.id))
    end)
    |> Multi.insert(
      :site_with_domain,
      fn %{site_with_internal_name: site} ->
        Ecto.build_assoc(site, :domains, %{
          name: "#{site.internal_name}#{Domains.affable_suffix()}"
        })
      end
    )
  end

  defp default_assets_multi(%Multi{} = multi) do
    multi
    |> asset_multi(:site_logo, "Logo", "gs://affable-uploads/default-logo.png")
    |> asset_multi(:header_image, "Header", "gs://affable-uploads/default-header.png")
    |> asset_multi(
      :golden_delicious,
      "Golden Delicious",
      "gs://affable-uploads/Mele_golden.jpg"
    )
    |> asset_multi(
      :gala,
      "Gala",
      "gs://affable-uploads/gala.jpg"
    )
    |> asset_multi(
      :bramley,
      "Bramley",
      "gs://affable-uploads/bramley.jpg"
    )
    |> asset_multi(
      :red_prince,
      "Red Prince",
      "gs://affable-uploads/Red_Prince_Aepfel.jpg"
    )
    |> asset_multi(
      :greensleeves,
      "Greensleeves",
      "gs://affable-uploads/greensleeves.jpg"
    )
    |> asset_multi(
      :red_delicious,
      "Red Delicious",
      "gs://affable-uploads/Red_Delicious_apples.jpg"
    )
    |> asset_multi(
      :pink_lady,
      "Pink Lady",
      "gs://affable-uploads/pink_lady.jpg"
    )
    |> asset_multi(
      :discovery,
      "Discovery",
      "gs://affable-uploads/Discovery_apples.jpg"
    )
    |> asset_multi(
      :braeburn,
      "Braeburn",
      "gs://affable-uploads/braeburn.jpg"
    )
    |> asset_multi(
      :coxs_orange_pippin,
      "Cox's Orange Pippin",
      "gs://affable-uploads/Cox_orange_renette2.JPG"
    )
    |> Multi.update(:site_with_default_assets, fn %{
                                                    header_image: header_image,
                                                    site_logo: site_logo,
                                                    site_with_internal_name: site
                                                  } ->
      site
      |> Site.changeset(%{
        site_logo_id: site_logo.id,
        header_image_id: header_image.id
      })
    end)
  end

  defp asset_multi(%Multi{} = multi, identifier, name, url) do
    Multi.insert(multi, identifier, &%Asset{site_id: &1.site.id, url: url, name: name})
  end

  defp default_items do
    [
      golden_delicious: %Item{
        position: 1,
        name: "Golden Delicious",
        description: "Yellow. Nothing like Red Delicious.",
        url: "https://commons.wikimedia.org/wiki/File:Mele_golden.jpg"
      },
      gala: %Item{
        position: 2,
        name: "Gala",
        description: "Red. Offspring of Red D and Kidd's Orange.",
        url: "https://commons.wikimedia.org/wiki/File:2015-02-xx_Gala_(apple).jpg"
      },
      bramley: %Item{
        position: 3,
        name: "Bramley",
        description: "Nice in a pie.",
        url: "https://commons.wikimedia.org/wiki/File:Bramley%27s_Seedling_Apples.jpg"
      },
      red_prince: %Item{
        position: 4,
        name: "Red Prince",
        description: "Holland made an apple. It's kinda red.",
        url: "https://commons.wikimedia.org/wiki/File:Red_Prince_Aepfel.jpg"
      },
      greensleeves: %Item{
        position: 5,
        name: "Greensleeves",
        description: "Parents are Golden D and James Grieve. That naughty James.",
        url:
          "https://commons.wikimedia.org/wiki/File:Greensleeves_on_tree,_National_Fruit_Collection_(acc._1980-077).jpg"
      },
      red_delicious: %Item{
        position: 6,
        name: "Red Delicious",
        description: "Dark Red. Popular in the states. Don't cook with it.",
        url: "https://commons.wikimedia.org/wiki/File:Red_Delicious_apples.jpg"
      },
      pink_lady: %Item{
        position: 7,
        name: "Pink Lady",
        description: "From the 70's. Light red / pink. Tasty.",
        url:
          "https://commons.wikimedia.org/wiki/File:Pink_lady_apples,_Thulimbah,_Granite_Belt,_Queensland,_2015_02.jpg"
      },
      discovery: %Item{
        position: 8,
        name: "Discovery",
        description: "Sweet flavour. English.",
        url: "https://commons.wikimedia.org/wiki/File:Discovery_apples.jpg"
      },
      braeburn: %Item{
        position: 9,
        name: "Braeburn",
        description: "Common in the UK supermarkets. Pretty good!",
        url: "https://commons.wikimedia.org/wiki/File:Braeburn2008.jpg"
      },
      coxs_orange_pippin: %Item{
        position: 10,
        name: "Cox's Orange Pippin",
        description: "Kind of a big deal in the UK.",
        url: "https://commons.wikimedia.org/wiki/File:Cox_orange_renette2.JPG"
      }
    ]
  end

  def update_site(%Site{} = site, attrs) do
    case site
         |> Site.changeset(attrs)
         |> Repo.update() do
      {:ok, site} ->
        {
          :ok,
          site
          |> preload_base_assets(force: true)
          |> with_items(force: true)
          |> broadcast()
        }

      otherwise ->
        otherwise
    end
  end

  def delete_site(%Site{} = site) do
    site
    |> delete_items()
    |> delete_assets()
    |> Repo.delete()
  end

  defp delete_items(%Site{} = site) do
    Repo.delete_all(from(Item, where: [site_id: ^site.id]))

    site
  end

  def delete_assets(%Site{} = site) do
    site =
      site
      |> change_site(%{header_image_id: nil, site_logo_id: nil})
      |> Repo.update!()

    Repo.delete_all(from(Asset, where: [site_id: ^site.id]))

    site
  end

  def change_site(%Site{} = site, attrs \\ %{}) do
    Site.changeset(site, attrs)
  end

  def promote_item(user, site, item_id) do
    if user |> member_of_site?(site) do
      move_item(site, item_id, &(&1 - 1))
    else
      {:error, :unauthorized}
    end
  end

  def demote_item(user, site, item_id) do
    if user |> member_of_site?(site) do
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
        |> with_items()
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

    (site |> Repo.preload(:items)).items
    |> Enum.reduce(multi, fn item, multi ->
      multi
      |> Multi.insert("item#{item.id}", fn %{definition: definition} ->
        Ecto.build_assoc(item, :attributes, %{definition_id: definition.id, value: "1.23"})
      end)
    end)
  end

  def add_attribute_definition(%Site{} = site, %User{} = user) do
    if user |> member_of_site?(site) do
      {:ok, _} =
        add_attribute_definition_multi(site)
        |> Repo.transaction()

      {:ok, get_site!(site.id) |> broadcast()}
    else
      {:error, :unauthorized}
    end
  end

  def member_of_site?(user, %Site{id: site_id}) do
    member_of_site?(user, site_id)
  end

  def member_of_site?(user, site_id) do
    Repo.exists?(from(SiteMember, where: [user_id: ^user.id, site_id: ^site_id]))
  end

  def delete_attribute_definition(site_id, definition_id, %User{} = user) do
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
        {:ok, get_site!(site_id) |> broadcast()}
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

  def append_item(site, user) do
    if user |> member_of_site?(site) do
      {:ok, %Item{} = item} =
        create_item(site, %{
          name: "New item",
          position: length(site.items) + 1,
          attributes:
            for definition <- site.attribute_definitions do
              %{
                definition_id: definition.id,
                value: "1.23"
              }
            end
        })

      {
        :ok,
        %{site | items: site.items ++ [item]}
        |> with_items()
        |> broadcast()
      }
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

  def delete_item(%Site{} = site, item_id) do
    item_id_s = "#{item_id}"

    {:ok, %{delete: deleted_item}} =
      site.items
      |> delete_item_multi(item_id_s)
      |> Repo.transaction()

    {
      :ok,
      site
      |> Map.update!(:items, fn items ->
        items
        |> Enum.reverse()
        |> Enum.reduce([], fn item, acc ->
          cond do
            item.id == deleted_item.id ->
              acc

            item.position > deleted_item.position ->
              [Map.update!(item, :position, &(&1 - 1)) | acc]

            true ->
              [item | acc]
          end
        end)
      end)
      |> broadcast()
    }
  end

  defp delete_item_multi(items, id) do
    delete_position =
      items
      |> Enum.find_value(&("#{&1.id}" == id && &1.position))

    items
    |> Enum.reduce(Ecto.Multi.new(), fn item, multi ->
      cond do
        "#{item.id}" == id ->
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

  def broadcast(%Site{} = site) do
    site = site |> with_items() |> preload_latest_publication()
    :ok = site |> (&broadcaster().broadcast(&1)).()

    site
  end

  defp broadcaster() do
    Application.get_env(:affable, :broadcaster)
  end
end
