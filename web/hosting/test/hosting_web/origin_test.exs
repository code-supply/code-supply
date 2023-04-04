defmodule HostingWeb.OriginTest do
  use Hosting.DataCase, async: true

  import HostingWeb.Origin

  alias Hosting.Domains.Domain

  test "unregistered domains are not allowed" do
    refute check_origin(%URI{
             authority: "some.domain.example.com",
             host: "some.domain.example.com",
             port: 4000,
             scheme: "http"
           })
  end

  test "site's domain is allowed on any port" do
    host = Application.get_env(:hosting, HostingWeb.Endpoint)[:url][:host]

    assert check_origin(%URI{
             authority: "#{host}:4000",
             host: "#{host}",
             port: 4000,
             scheme: "http"
           })

    assert check_origin(%URI{
             authority: "#{host}:1234",
             host: "#{host}",
             port: 4000,
             scheme: "http"
           })
  end

  test "domains in the database are allowed" do
    {:ok, _domain} =
      %Domain{}
      |> Domain.changeset(%{name: "foo.example.com"})
      |> Repo.insert()

    assert check_origin(%URI{
             authority: "foo.example.com",
             host: "foo.example.com",
             port: 4000,
             scheme: "http"
           })
  end
end
