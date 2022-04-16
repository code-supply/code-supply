defmodule Affable.Sites do
  import Ecto.Query, warn: false

  alias Affable.Sites.{Page, Section, TitleUtils, Raw}
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

  @section_preloads [image: []]

  def update_page(%Page{} = page, attrs, %User{} = user) do
    with :ok <- must_be_site_member(user, page),
         {:ok, page} <-
           page
           |> Page.changeset(attrs)
           |> Repo.update() do
      {:ok, page |> Repo.preload(page_preloads())}
    else
      err -> err
    end
  end

  def add_page(%Site{pages: pages} = site, user) do
    with :ok <- must_be_site_member(user, site),
         page_title <-
           TitleUtils.generate(
             for(p <- pages, do: p.path),
             "/untitled-page",
             "Untitled page"
           )
           |> Enum.join(" "),
         {:ok, page} <-
           site
           |> Ecto.build_assoc(:pages, %{
             title: page_title,
             path: TitleUtils.to_path(page_title)
           })
           |> Repo.insert() do
      {:ok, page |> Repo.preload(page_preloads())}
    else
      err -> err
    end
  end

  def delete_page(id, user) do
    %Page{} = page = Repo.get(Page, id)

    if user |> site_member?(page) do
      Repo.delete(page)
    else
      {:error, :unauthorized}
    end
  end

  def page_ids(%Site{} = site) do
    for p <- Repo.all(Ecto.assoc(site, :pages) |> order_by(:id)) do
      p.id
    end
  end

  def add_page_section(page, user) do
    update_page(
      page,
      %{
        sections:
          Enum.map(page.sections, &Map.from_struct/1) ++
            [
              %{
                name:
                  TitleUtils.generate(
                    for(s <- page.sections, do: s.name),
                    "untitled-section",
                    "untitled-section"
                  )
                  |> Enum.join("-"),
                image: nil
              }
            ]
      },
      user
    )
  end

  def delete_page_section(id, user) do
    %Section{page_id: page_id} = section = Repo.get(Section, id)

    page = Repo.get!(Page, page_id)

    with :ok <- must_be_site_member(user, page),
         {:ok, section} <- Repo.delete(section) do
      {:ok, section}
    else
      err -> err
    end
  end

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

    {:ok, site}
  end

  def is_published?(%Site{id: id} = site) do
    latest_publication =
      from(p in Publication, where: [site_id: ^id], order_by: [desc: p.id], limit: 1)
      |> Repo.one()

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

  def preview_url(%Site{domains: domains} = site) do
    case Enum.find(domains, &Domains.affable_domain?(&1)) do
      nil ->
        preview_url(%{site | domains: Enum.drop(domains, 1)})

      domain ->
        "//#{domain.name}/preview"
    end
  end

  def default_path([]) do
    "/"
  end

  def default_path([first | _] = paths) do
    case Enum.find(paths, &(&1 == "/")) do
      nil -> first
      path -> path
    end
  end

  def get_site!(user, id) do
    site_query(id)
    |> join(:inner, [s], m in SiteMember, on: s.id == m.site_id)
    |> where([s, m], m.user_id == ^user.id)
    |> Repo.one!()
    |> with_items()
    |> with_pages()
  end

  def get_site!(%Site{id: id}) do
    get_site!(id)
  end

  def get_site!(id) do
    site_query(id)
    |> Repo.one!()
    |> with_items()
    |> with_pages()
    |> preload_latest_publication()
  end

  defp site_query(id) do
    definitions_q = definitions_query()

    from(s in Site,
      where: s.id == ^id,
      preload: [
        assets: [],
        domains: [],
        members: [],
        site_logo: [],
        attribute_definitions: ^definitions_q
      ]
    )
  end

  def reload_assets(%Site{} = site) do
    Repo.preload(site, [assets: Assets.default_query()], force: true)
  end

  defp preload_base_assets(site, opts \\ []) do
    Repo.preload(site, [:site_logo], opts)
  end

  defp preload_latest_publication(site) do
    site
    |> preload_base_assets
    |> Repo.preload(latest_publication: from(p in Publication, order_by: [desc: p.id]))
  end

  def with_pages(site, attrs \\ []) do
    site
    |> Repo.preload(
      [
        available_layouts: [],
        layout: [sections: @section_preloads],
        pages: page_query()
      ],
      attrs
    )
  end

  defp page_query() do
    from p in Page, order_by: p.id, preload: ^page_preloads()
  end

  defp page_preloads() do
    [items: items_query(), sections: @section_preloads, header_image: []]
  end

  def with_items(site, attrs \\ []) do
    site
    |> Repo.preload([attribute_definitions: definitions_query()], attrs)
  end

  defp items_query do
    attributes_q = from(a in Attribute, order_by: [desc: a.definition_id], preload: :definition)

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
    |> add_homepage_multi()
    |> Multi.insert(:publish, &build_publication(&1.site))
  end

  def create_site_multi(user, attrs) do
    Multi.new()
    |> site_with_name_multi(user, attrs)
    |> add_homepage_multi(%{
      header_text: """
      # Top 10 Apples

      The apple is a deciduous tree, generally standing 2 to 4.5 m (6 to 15 ft) tall in cultivation and up to 9 m (30 ft) in the wild. When cultivated, the size, shape and branch density are determined by rootstock selection and trimming method. The leaves are alternately arranged dark green-colored simple ovals with serrated margins and slightly downy undersides.
      """
    })
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

  defp add_homepage_multi(%Multi{} = multi, attrs \\ %{}) do
    Multi.insert(multi, :homepage, fn %{site: site} ->
      Ecto.build_assoc(site, :pages, Map.merge(%{title: "Home"}, attrs))
    end)
  end

  defp default_items_multi(%Multi{} = multi) do
    Enum.reduce(default_items(), multi, fn {identifier, item}, multi ->
      Multi.insert(
        multi,
        "item#{item.position}",
        fn %{homepage: homepage, definition: definition} = previous_multis ->
          %{
            item
            | page_id: homepage.id,
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
          |> with_pages()
          |> Repo.preload(site_logo: [])
        )
    })
  end

  defp site_with_name_multi(%Multi{} = multi, user, attrs) do
    multi
    |> Multi.insert(
      :site,
      %Site{}
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
    |> Multi.update(:homepage_with_default_assets, fn %{
                                                        header_image: header_image,
                                                        homepage: homepage
                                                      } ->
      Page.changeset(homepage, %{header_image_id: header_image.id})
    end)
    |> Multi.update(:site_with_default_assets, fn %{
                                                    site_logo: site_logo,
                                                    site_with_internal_name: site
                                                  } ->
      Site.changeset(site, %{site_logo_id: site_logo.id})
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
          |> with_pages(force: true)
        }

      otherwise ->
        otherwise
    end
  end

  def delete_site(%Site{} = site) do
    site
    |> delete_items()
    |> delete_pages()
    |> delete_assets()
    |> Repo.delete()
  end

  defp delete_pages(%Site{} = site) do
    Repo.delete_all(from(Page, where: [site_id: ^site.id]))

    site
  end

  defp delete_items(%Site{} = site) do
    Repo.delete_all(from(Item, where: [site_id: ^site.id]))

    site
  end

  def delete_assets(%Site{} = site) do
    site =
      site
      |> change_site(%{site_logo_id: nil})
      |> Repo.update!()

    Repo.delete_all(from(Asset, where: [site_id: ^site.id]))

    site
  end

  def change_site(%Site{} = site, attrs \\ %{}) do
    Site.changeset(site, attrs)
  end

  def promote_item(%Site{} = site, %Page{} = page, item_id) do
    move_item(site, page, item_id, &(&1 - 1))
  end

  def demote_item(%Site{} = site, %Page{} = page, item_id) do
    move_item(site, page, item_id, &(&1 + 1))
  end

  defp move_item(%Site{} = site, %Page{} = page, item_id, f) do
    {item_id, ""} = Integer.parse(item_id)

    demotee_idx =
      page.items
      |> Enum.find_index(&(&1.id == item_id))

    demotee = page.items |> Enum.at(demotee_idx)

    promotee_idx =
      page.items
      |> Enum.find_index(&(&1.position == f.(demotee.position)))

    if promotee_idx do
      promotee = page.items |> Enum.at(promotee_idx)

      {:ok, %{promote: promoted_item, demote: demoted_item}} =
        move_item_multi(demotee, promotee, f)
        |> Repo.transaction()

      {
        :ok,
        %{
          site
          | pages:
              for p <- site.pages do
                if p.id == page.id do
                  %{
                    p
                    | items:
                        p.items
                        |> List.replace_at(promotee_idx, promoted_item)
                        |> List.replace_at(demotee_idx, demoted_item)
                        |> Enum.sort_by(& &1.position)
                  }
                else
                  p
                end
              end
        }
        |> with_items()
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

    Repo.preload(site, pages: :items).pages
    |> Enum.flat_map(& &1.items)
    |> Enum.reduce(multi, fn item, acc_multi ->
      acc_multi
      |> Multi.insert("item#{item.id}", fn %{definition: definition} ->
        Ecto.build_assoc(item, :attributes, %{definition_id: definition.id, value: "1.23"})
      end)
    end)
  end

  def add_attribute_definition(%Site{} = site, %User{} = user) do
    with :ok <- must_be_site_member(user, site),
         {:ok, _} <- Repo.transaction(add_attribute_definition_multi(site)) do
      {:ok, get_site!(site.id)}
    else
      err -> err
    end
  end

  def site_member?(user, %Site{id: site_id}) do
    site_member?(user, site_id)
  end

  def site_member?(user, %{site_id: site_id}) do
    site_member?(user, site_id)
  end

  def site_member?(user, site_id) do
    Repo.exists?(from(SiteMember, where: [user_id: ^user.id, site_id: ^site_id]))
  end

  def must_be_site_member(user, obj) do
    if user |> site_member?(obj) do
      :ok
    else
      {:error, :unauthorized}
    end
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
        {:ok, get_site!(site_id)}
    end
  end

  alias Affable.Sites.Item

  def get_item!(id), do: Repo.get!(Item, id)

  def append_item(%Site{} = site, %Page{} = page, %User{} = user) do
    with :ok <- must_be_site_member(user, page),
         {:ok, %Item{} = item} <-
           create_item(page, %{
             name: "New item",
             position: length(page.items) + 1,
             attributes:
               for definition <- site.attribute_definitions do
                 %{
                   definition_id: definition.id,
                   value: "1.23"
                 }
               end
           }) do
      {
        :ok,
        %{
          site
          | pages:
              for p <- site.pages do
                if p.id == page.id do
                  %{page | items: page.items ++ [item]}
                else
                  page
                end
              end
        }
        |> with_pages(force: true),
        item
      }
    else
      err -> err
    end
  end

  defp create_item(page, attrs) do
    page
    |> Ecto.build_assoc(:items)
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def delete_item(%Site{}, %Page{} = page, item_id) do
    item_id_s = "#{item_id}"

    {:ok, %{delete: deleted_item}} =
      page.items
      |> delete_item_multi(item_id_s)
      |> Repo.transaction()

    new_page = remove_item_from_page(page, deleted_item)

    {:ok, new_page}
  end

  defp remove_item_from_page(page, deleted_item) do
    %{
      page
      | items:
          page.items
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
end
