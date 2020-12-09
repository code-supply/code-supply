defmodule AffableWeb.AssetsLiveTest do
  use AffableWeb.ConnCase, async: true
  import Affable.AccountsFixtures

  alias Affable.Accounts

  setup context do
    %{conn: conn, user: user} = register_and_log_in_user(context)

    token =
      extract_user_token(fn url ->
        Accounts.deliver_user_confirmation_instructions(user, url)
      end)

    Accounts.confirm_user(token)

    {:ok, %{conn: conn, user: user}}
  end
end
