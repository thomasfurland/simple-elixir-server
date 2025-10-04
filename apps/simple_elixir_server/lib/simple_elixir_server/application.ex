defmodule SimpleElixirServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SimpleElixirServer.Repo,
      {DNSCluster,
       query: Application.get_env(:simple_elixir_server, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SimpleElixirServer.PubSub}
      # Start a worker by calling: SimpleElixirServer.Worker.start_link(arg)
      # {SimpleElixirServer.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: SimpleElixirServer.Supervisor)
  end
end
