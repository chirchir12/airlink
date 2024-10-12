defmodule Airlink.Repo do
  use Ecto.Repo,
    otp_app: :airlink,
    adapter: Ecto.Adapters.Postgres
end
