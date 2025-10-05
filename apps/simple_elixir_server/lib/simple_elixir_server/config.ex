defmodule SimpleElixirServer.Config do
  @app :simple_elixir_server

  def mail_sender, do: Application.get_env(@app, :mail_sender, "contact@example.com")
end
