defmodule SimpleElixirServerWeb.PageController do
  use SimpleElixirServerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
