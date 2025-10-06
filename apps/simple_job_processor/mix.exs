defmodule SimpleJobProcessor.MixProject do
  use Mix.Project

  def project do
    [
      app: :simple_job_processor,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.20-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {SimpleJobProcessor.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:oban, "~> 2.20"},
      {:simple_elixir_server, in_umbrella: true}
    ]
  end
end
