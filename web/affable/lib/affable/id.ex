defmodule Affable.ID do
  def site_name_from_id(id) do
    "site#{encode(id)}"
  end

  def id_from_site_name(name) do
    name
    |> String.replace_prefix("site", "")
    |> decode()
  end

  defp encode(num) do
    hashids()
    |> Hashids.encode(num)
  end

  defp decode(str) do
    [id] =
      hashids()
      |> Hashids.decode!(str)

    id
  end

  defp hashids do
    salt = Application.get_env(:affable, :id_salt)

    Hashids.new(
      salt: salt,
      alphabet: "abcdefghijklmnopqrstuvwxyz1234567890",
      min_len: 4
    )
  end
end
