# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Affable.Repo.insert!(%Affable.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Affable.Accounts

if Mix.env() == :dev do
  {:ok, user} =
    Affable.Accounts.register_user(%{
      email: "a@example.com",
      password: "asdfasdfasdf"
    })

  extract_user_token = fn fun ->
    {:ok, captured} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token, _] = String.split(captured.body, "[TOKEN]")
    token
  end

  token =
    extract_user_token.(fn url ->
      Accounts.deliver_user_confirmation_instructions(user, url)
    end)

  Accounts.confirm_user(token)
end
