defmodule HostingWeb.ConnCase do
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
  by setting `use HostingWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import HostingWeb.ConnCase

      alias HostingWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint HostingWeb.Endpoint

      use HostingWeb, :verified_routes
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Hosting.Repo)

    unless tags[:async] do
      Sandbox.mode(Hosting.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  def register_and_log_in_unconfirmed_user(%{conn: conn}) do
    user = Hosting.AccountsFixtures.unconfirmed_user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  def register_and_log_in_user(%{conn: conn}) do
    user = Hosting.AccountsFixtures.user_fixture()
    %{conn: log_in_user(conn, user), user: user}
  end

  def log_in_user(conn, user) do
    token = Hosting.Accounts.generate_user_session_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
  end

  def control_plane_path(path) do
    "http://#{Application.get_env(:hosting, HostingWeb.Endpoint)[:url][:host]}#{path}"
  end

  def select_page_tab(n) do
    select_page_menu_item(n + 1)
  end

  def select_page_menu_item(n) do
    "#page-nav ul li:nth-child(#{n}) a"
  end

  def app_domain do
    Application.get_env(:hosting, HostingWeb.Endpoint)[:url][:host]
  end
end
