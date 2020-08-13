defmodule Affable.ID do
  def encode(num) do
    salt = Application.get_env(:affable, :id_salt)

    s =
      Hashids.new(
        salt: salt,
        alphabet: "abcdefghijklmnopqrstuvwxyz1234567890",
        min_len: 4
      )

    Hashids.encode(s, num)
  end
end
