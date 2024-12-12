defmodule TermProject.Repo do
  use Ecto.Repo,
    otp_app: :term_project,
    adapter: Ecto.Adapters.Postgres
end
