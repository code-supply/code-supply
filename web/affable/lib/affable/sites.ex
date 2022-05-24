defmodule Affable.Sites do
  import Ecto.Query, warn: false

  alias Affable.Sites.{
    Page,
    Publication,
    Raw,
    Section,
    Site,
    SiteMember,
    TitleUtils
  }

  alias Affable.Repo
  alias Affable.Accounts.User
  alias Affable.Assets
  alias Affable.Assets.Asset
  alias Affable.Domains
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

  def publish(site) do
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
    |> with_pages()
  end

  def get_site!(%Site{id: id}) do
    get_site!(id)
  end

  def get_site!(id) do
    site_query(id)
    |> Repo.one!()
    |> with_pages()
    |> preload_latest_publication()
  end

  defp site_query(id) do
    from(s in Site,
      where: s.id == ^id,
      preload: [
        assets: [],
        domains: [],
        members: []
      ]
    )
  end

  def reload_assets(%Site{} = site) do
    Repo.preload(site, [assets: Assets.default_query()], force: true)
  end

  defp preload_latest_publication(site) do
    site
    |> Repo.preload(latest_publication: from(p in Publication, order_by: [desc: p.id]))
  end

  def with_pages(site, attrs \\ []) do
    site
    |> Repo.preload(
      [
        layouts: [],
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
    [sections: @section_preloads, header_image: []]
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
    |> handle_create_site_multi(:site_with_internal_name)
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
    |> Multi.insert(:publish, &build_publication(&1.site_with_internal_name))
  end

  defp handle_create_site_multi(result, site_multi_key) do
    case result do
      {:ok, multis} ->
        {
          :ok,
          multis[site_multi_key]
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

  defp build_publication(site) do
    Ecto.build_assoc(site, :publications, %{data: raw(site |> with_pages())})
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
  end

  defp asset_multi(%Multi{} = multi, identifier, name, url) do
    Multi.insert(multi, identifier, &%Asset{site_id: &1.site.id, url: url, name: name})
  end

  def update_site(%Site{} = site, attrs) do
    case site
         |> Site.changeset(attrs)
         |> Repo.update() do
      {:ok, site} ->
        {
          :ok,
          site
          |> with_pages(force: true)
        }

      otherwise ->
        otherwise
    end
  end

  def delete_site(%Site{} = site) do
    site
    |> delete_pages()
    |> delete_assets()
    |> Repo.delete()
  end

  defp delete_pages(%Site{} = site) do
    Repo.delete_all(from(Page, where: [site_id: ^site.id]))

    site
  end

  def delete_assets(%Site{} = site) do
    Repo.delete_all(from(Asset, where: [site_id: ^site.id]))
    site
  end

  def change_site(%Site{} = site, attrs \\ %{}) do
    Site.changeset(site, attrs)
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
end
