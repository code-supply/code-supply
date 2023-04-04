defmodule HostingWeb.UserLoginLive do
  use HostingWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="container">
      <h1>
        Log in
      </h1>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
        </:actions>
        <:actions>
          <.button phx-disable-with="Signing in..." class="w-full">
            Log in
          </.button>
        </:actions>
      </.simple_form>

      <p>
        <.link navigate={~p"/users/register"}>
          Register
        </.link>
        |
        <.link href={~p"/users/reset_password"}>
          Forgot your password?
        </.link>
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
