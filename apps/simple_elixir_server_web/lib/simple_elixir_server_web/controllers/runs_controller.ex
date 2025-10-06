defmodule SimpleElixirServerWeb.RunsController do
  use SimpleElixirServerWeb, :controller

  alias SimpleElixirServer.Runs

  def index(conn, _params) do
    user_id = conn.assigns.current_scope.user.id
    {:ok, runs} = Runs.find_all(%{user_id: user_id})
    render(conn, :index, runs: runs)
  end

  def show(conn, %{"id" => id}) do
    case Runs.find(id) do
      {:ok, run} -> render(conn, :show, run: run)
      {:error, :not_found} -> put_status(conn, :not_found) |> render(:show, run: nil)
    end
  end
end
