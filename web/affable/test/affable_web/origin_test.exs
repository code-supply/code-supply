defmodule AffableWeb.OriginTest do
  use Affable.DataCase, async: true

  import AffableWeb.Origin

  alias Affable.Domains.Domain

  test "unregistered domains are not allowed" do
    refute check_origin(%URI{
             authority: "some.domain.example.com",
             host: "some.domain.example.com",
             port: 4000,
             scheme: "http"
           })
  end

  test "localhost is allowed on any port" do
    assert check_origin(%URI{
             authority: "localhost:4000",
             host: "localhost",
             port: 4000,
             scheme: "http"
           })

    assert check_origin(%URI{
             authority: "localhost:1234",
             host: "localhost",
             port: 4000,
             scheme: "http"
           })
  end

  test "www.affable.app is allowed" do
    assert check_origin(%URI{
             authority: "www.affable.app",
             host: "localhost",
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
