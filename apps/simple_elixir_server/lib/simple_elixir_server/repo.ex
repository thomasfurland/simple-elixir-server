defmodule SimpleElixirServer.Repo do
  use Ecto.Repo,
    otp_app: :simple_elixir_server,
    adapter: Ecto.Adapters.Postgres
end
