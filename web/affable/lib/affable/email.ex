defmodule Affable.Email do
  import Bamboo.Email
  use Bamboo.Phoenix, view: Affable.EmailView

  def reset_password_instructions(user, url) do
    new_email()
    |> to(user.email)
    |> subject("Affable password reset request")
    |> from("noreply@affable.app")
    |> render(:reset_password, url: url)
  end

  def confirmation_instructions(user, url) do
    new_email()
    |> to(user.email)
    |> subject("Confirmation of your Affable account")
    |> from("noreply@affable.app")
    |> render(:confirmation_instructions, url: url)
  end
end
