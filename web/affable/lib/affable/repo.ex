defmodule Affable.Repo do
  use Ecto.Repo,
    otp_app: :affable,
    adapter: Ecto.Adapters.Postgres
end
