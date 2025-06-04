defmodule Tasty.Repo do
  use Ecto.Repo,
    otp_app: :tasty,
    adapter: Ecto.Adapters.Postgres
end
