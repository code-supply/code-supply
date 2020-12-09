defmodule AffableWeb.AssetsLiveTest do
  use AffableWeb.ConnCase, async: true

  setup context do
    {:ok, register_and_log_in_user(context)}
  end

  test "can upload an image for one the user's sites", %{conn: _conn, user: _user} do
  end
end
