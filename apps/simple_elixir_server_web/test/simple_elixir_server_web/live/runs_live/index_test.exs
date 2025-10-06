defmodule SimpleElixirServerWeb.RunsLive.IndexTest do
  use SimpleElixirServerWeb.ConnCase
  use Oban.Testing, repo: SimpleElixirServer.Repo

  import Phoenix.LiveViewTest
  import SimpleElixirServer.AccountsFixtures
  import SimpleElixirServer.RunsFixtures

  describe "Index page" do
    setup :register_and_log_in_user

    test "renders runs page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/runs")

      assert html =~ "Runs"
      assert html =~ "New Run"
    end

    test "lists all runs for the current user", %{conn: conn, user: user} do
      run1 = run_fixture(%{user_id: user.id, title: "First Run"})
      run2 = run_fixture(%{user_id: user.id, title: "Second Run"})

      {:ok, _lv, html} = live(conn, ~p"/runs")

      assert html =~ run1.title
      assert html =~ run2.title
    end

    test "does not list runs from other users", %{conn: conn, user: user} do
      other_user = user_fixture()
      other_run = run_fixture(%{user_id: other_user.id, title: "Other User Run"})
      my_run = run_fixture(%{user_id: user.id, title: "My Run"})

      {:ok, _lv, html} = live(conn, ~p"/runs")

      assert html =~ my_run.title
      refute html =~ other_run.title
    end

    test "shows empty state when user has no runs", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/runs")

      assert html =~ "No runs yet"
      assert html =~ "Get started by creating your first run"
    end

    test "requires authentication", %{conn: _conn} do
      conn = build_conn()
      result = live(conn, ~p"/runs")

      assert {:error, {:redirect, %{to: "/users/log-in"}}} = result
    end
  end

  describe "Modal" do
    setup :register_and_log_in_user

    test "opens create modal on button click", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/runs")

      refute has_element?(lv, "#run-modal")

      lv |> element("button", "New Run") |> render_click()

      assert has_element?(lv, "#run-modal")
      assert has_element?(lv, "h3", "Create New Run")
    end

    test "closes modal on cancel", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/runs")

      lv |> element("button", "New Run") |> render_click()
      assert has_element?(lv, "#run-modal")

      lv |> element("button", "Cancel") |> render_click()
      refute has_element?(lv, "#run-modal")
    end

    test "creates run with title", %{conn: conn, user: _user} do
      {:ok, lv, _html} = live(conn, ~p"/runs")

      lv |> element("button", "New Run") |> render_click()

      csv_content = "open,high,low,close\n100,110,95,105\n101,111,96,106"

      file =
        file_input(lv, "#run-modal", :candlestick_data, [
          %{
            last_modified: 1_594_171_879_000,
            name: "test.csv",
            content: csv_content,
            type: "text/csv"
          }
        ])

      render_upload(file, "test.csv")

      lv
      |> form("#run-form", %{title: "New Test Run"})
      |> render_submit()

      html = render(lv)
      assert html =~ "New Test Run"
      assert html =~ "Run created successfully"
      refute has_element?(lv, "#run-modal")
    end

    test "creates run without title", %{conn: conn, user: _user} do
      {:ok, lv, _html} = live(conn, ~p"/runs")

      lv |> element("button", "New Run") |> render_click()

      csv_content = "open,high,low,close\n100,110,95,105\n101,111,96,106"

      file =
        file_input(lv, "#run-modal", :candlestick_data, [
          %{
            last_modified: 1_594_171_879_000,
            name: "test.csv",
            content: csv_content,
            type: "text/csv"
          }
        ])

      render_upload(file, "test.csv")

      lv
      |> form("#run-form", %{title: ""})
      |> render_submit()

      html = render(lv)
      assert html =~ "Untitled Run"
      assert html =~ "Run created successfully"
    end

    test "creates run with generated outcomes", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/runs")

      lv |> element("button", "New Run") |> render_click()

      csv_content = "open,high,low,close\n100,110,95,105\n101,111,96,106"

      file =
        file_input(lv, "#run-modal", :candlestick_data, [
          %{
            last_modified: 1_594_171_879_000,
            name: "test.csv",
            content: csv_content,
            type: "text/csv"
          }
        ])

      render_upload(file, "test.csv")

      lv
      |> form("#run-form", %{title: "Test Run"})
      |> render_submit()

      {:ok, runs} = SimpleElixirServer.Runs.find_all(%{user_id: user.id})
      run = Enum.find(runs, &(&1.title == "Test Run"))

      assert run.outcomes["status"] == "pending"
      assert run.outcomes["generated_at"]
    end

    test "modal shows job runner dropdown", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/runs")

      lv |> element("button", "New Run") |> render_click()

      assert has_element?(lv, "select[name='job_runner']")
      assert has_element?(lv, "option", "Data Processing")
      assert has_element?(lv, "option", "Event Analysis")
    end

    test "enqueues oban job when job runner is selected", %{conn: conn, user: _user} do
      {:ok, lv, _html} = live(conn, ~p"/runs")

      lv |> element("button", "New Run") |> render_click()

      csv_content = "open,high,low,close\n100,110,95,105\n101,111,96,106"

      file =
        file_input(lv, "#run-modal", :candlestick_data, [
          %{
            last_modified: 1_594_171_879_000,
            name: "test.csv",
            content: csv_content,
            type: "text/csv"
          }
        ])

      render_upload(file, "test.csv")

      lv
      |> form("#run-form", %{title: "Test Run with Job", job_runner: "data_processing"})
      |> render_submit()

      assert_enqueued(worker: SimpleJobProcessor.Workers.DataProcessing)
    end
  end
end
