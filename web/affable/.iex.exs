import Ecto.Query, warn: false
alias Affable.Accounts
alias Affable.Repo
alias Affable.Sites
alias Affable.Sites.Page
alias Affable.Sites.Site
alias Affable.Layouts
alias Affable.Layouts.Layout
u = Accounts.get_user!(1)
s = Sites.get_site!(1)
