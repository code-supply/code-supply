defmodule Hosting.Repo do
  use Ecto.Repo,
    otp_app: :hosting,
    adapter: Ecto.Adapters.Postgres
end
