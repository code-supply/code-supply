defmodule AffableWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use AffableWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import AffableWeb.ConnCase

      alias AffableWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint AffableWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Affable.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Affable.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def register_and_log_in_unconfirmed_user(%{conn: conn}) do
    user = Affable.AccountsFixtures.unconfirmed_user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  def register_and_log_in_user(%{conn: conn}) do
    user = Affable.AccountsFixtures.user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  def log_in_user(conn, user) do
    token = Affable.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end

  def control_plane_path(path) do
    "http://localhost#{path}"
  end
end
