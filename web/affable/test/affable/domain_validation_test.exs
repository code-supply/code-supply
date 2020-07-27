defmodule Affable.DomainValidationTest do
  use Affable.DataCase

  alias Affable.Domains.Domain

  test "denies direct UTF-8 special chars" do
    assert "must be a valid domain" in errors_on(domain("♡.com"), :name)
  end

  test "denies nil" do
    assert "can't be blank" in errors_on(domain(nil), :name)
  end

  test "denies top level domains" do
    assert "must be a valid domain" in errors_on(domain("toplevel"), :name)
  end

  test "denies spaces" do
    assert "must be a valid domain" in errors_on(domain("my domain.com"), :name)
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
