defmodule Affable.DomainValidationTest do
  use Affable.DataCase, async: true

  alias Affable.Domains.Domain

  test "multiple subdomains permitted" do
    assert errors_on(domain("www.a.b.c"), :name) == []
  end

  test "including scheme is an error" do
    assert "must be a valid domain" in errors_on(domain("ftp://www.a.b.c"), :name)
  end

  test "including user is an error" do
    assert "must be a valid domain" in errors_on(domain("bob@www.a.b.c"), :name)
  end

  test "including fragment is an error" do
    assert "must be a valid domain" in errors_on(domain("www.a.b.c/#hi"), :name)
  end

  test "including port is an error" do
    assert "must be a valid domain" in errors_on(domain("www.a.b.c:8080"), :name)
  end

  test "including query is an error" do
    assert "must be a valid domain" in errors_on(domain("www.a.b.c?hi=there"), :name)
  end

  test "denies nil" do
    assert "can't be blank" in errors_on(domain(nil), :name)
  end

  test "denies spaces" do
    assert "domains don't have spaces" in errors_on(domain("my domain.com"), :name)
  end

  test "denies leading dot" do
    assert "cannot begin with a dot" in errors_on(domain(".mydomain.com"), :name)
  end

  test "permits xn prefix" do
    assert domain("xn--c6h.com").errors == []
    assert domain("xn--stackoverflow.com").errors == []
  end

  def errors_on(changeset, field) do
    for {message, opts} <- Keyword.get_values(changeset.errors, field) do
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end
  end

  defp domain(name) do
    Domain.changeset(%Domain{}, %{user_id: 1, name: name})
  end
end
