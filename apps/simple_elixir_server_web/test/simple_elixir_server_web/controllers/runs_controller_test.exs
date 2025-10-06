defmodule SimpleElixirServerWeb.RunsControllerTest do
  use SimpleElixirServerWeb.ConnCase

  import SimpleElixirServer.AccountsFixtures
  import SimpleElixirServer.RunsFixtures

  describe "index" do
    setup :register_and_log_in_user

    test "lists all runs for the current user", %{conn: conn, user: user} do
      run1 = run_fixture(%{user_id: user.id, title: "First Run"})
      run2 = run_fixture(%{user_id: user.id, title: "Second Run"})

      conn = get(conn, ~p"/runs")
      response = html_response(conn, 200)

      assert response =~ "Runs"
      assert response =~ run1.title
      assert response =~ run2.title
    end

    test "does not list runs from other users", %{conn: conn, user: user} do
      other_user = user_fixture()
      other_run = run_fixture(%{user_id: other_user.id, title: "Other User Run"})
      my_run = run_fixture(%{user_id: user.id, title: "My Run"})

      conn = get(conn, ~p"/runs")
      response = html_response(conn, 200)

      assert response =~ my_run.title
      refute response =~ other_run.title
    end

    test "shows empty state when user has no runs", %{conn: conn} do
      conn = get(conn, ~p"/runs")
      response = html_response(conn, 200)

      assert response =~ "No runs yet"
      assert response =~ "Get started by creating your first run"
    end

    test "displays run metadata correctly", %{conn: conn, user: user} do
      run =
        run_fixture(%{user_id: user.id, title: "Test Run", outcomes: %{"status" => "success"}})

      conn = get(conn, ~p"/runs")
      response = html_response(conn, 200)

      assert response =~ to_string(run.id)
      assert response =~ run.title
      assert response =~ "1 results"
    end

    test "handles runs without outcomes", %{conn: conn, user: user} do
      run = run_fixture(%{user_id: user.id, title: "Run No Outcomes", outcomes: nil})

      conn = get(conn, ~p"/runs")
      response = html_response(conn, 200)

      assert response =~ run.title
      assert response =~ "No outcomes"
    end

    test "handles runs without title", %{conn: conn, user: user} do
      _run = run_fixture(%{user_id: user.id, title: nil})

      conn = get(conn, ~p"/runs")
      response = html_response(conn, 200)

      assert response =~ "Untitled Run"
    end

    test "requires authentication", %{conn: _conn} do
      conn = build_conn()
      conn = get(conn, ~p"/runs")
      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end

  describe "show" do
    setup :register_and_log_in_user

    test "displays run details", %{conn: conn, user: user} do
      run = run_fixture(%{user_id: user.id, title: "Detailed Run", outcomes: %{"key" => "value"}})

      conn = get(conn, ~p"/runs/#{run.id}")
      response = html_response(conn, 200)

      assert response =~ run.title
      assert response =~ to_string(run.id)
      assert response =~ "Outcomes"
    end

    test "displays run without title", %{conn: conn, user: user} do
      run = run_fixture(%{user_id: user.id, title: nil})

      conn = get(conn, ~p"/runs/#{run.id}")
      response = html_response(conn, 200)

      assert response =~ "Untitled Run"
    end

    test "displays run without outcomes", %{conn: conn, user: user} do
      run = run_fixture(%{user_id: user.id, outcomes: nil})

      conn = get(conn, ~p"/runs/#{run.id}")
      response = html_response(conn, 200)

      assert response =~ "No outcomes recorded"
    end

    test "shows not found page for non-existent run", %{conn: conn} do
      conn = get(conn, ~p"/runs/99999")
      response = html_response(conn, 404)

      assert response =~ "Run Not Found"
      assert response =~ "Back to Runs"
    end

    test "requires authentication", %{conn: _conn, user: user} do
      run = run_fixture(%{user_id: user.id})
      conn = build_conn()
      conn = get(conn, ~p"/runs/#{run.id}")
      assert redirected_to(conn) == ~p"/users/log-in"
    end

    test "includes back link to runs page", %{conn: conn, user: user} do
      run = run_fixture(%{user_id: user.id})

      conn = get(conn, ~p"/runs/#{run.id}")
      response = html_response(conn, 200)

      assert response =~ "Back to runs"
      assert response =~ ~p"/runs"
    end
  end
end
