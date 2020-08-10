defmodule Affable.Email do
  import Bamboo.Email
  use Bamboo.Phoenix, view: Affable.EmailView

  def reset_password_instructions(user, url) do
    new_email()
    |> to(user.email)
    |> subject("Affable password reset request")
    |> from("passwordreset@affable.app")
    |> render(:reset_password, url: url)
  end
end
