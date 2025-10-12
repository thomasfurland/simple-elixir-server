defmodule SimpleElixirServerWeb.Components.NavTest do
  use SimpleElixirServerWeb.ConnCase, async: true

  import Phoenix.Component, only: [sigil_H: 2]
  import Phoenix.LiveViewTest
  alias SimpleElixirServerWeb.Components.Nav

  describe "drawer/1" do
    test "renders navigation drawer with authenticated menu items when user is logged in" do
      current_scope = %{user: %{email: "test@example.com"}}
      assigns = %{current_scope: current_scope}

      html =
        rendered_to_string(~H"""
        <Nav.drawer current_scope={@current_scope} />
        """)

      assert html =~ "test@example.com"
      assert html =~ "Home"
      assert html =~ "Runs"
      assert html =~ "Settings"
      assert html =~ "Log out"
      refute html =~ "Register"
      refute html =~ "Log in"
    end

    test "renders navigation drawer with auth menu items when user is not logged in" do
      assigns = %{current_scope: nil}

      html =
        rendered_to_string(~H"""
        <Nav.drawer current_scope={@current_scope} />
        """)

      assert html =~ "Register"
      assert html =~ "Log in"
      refute html =~ "Home"
      refute html =~ "Settings"
      refute html =~ "Log out"
    end

    test "includes theme toggle in drawer" do
      assigns = %{current_scope: nil}

      html =
        rendered_to_string(~H"""
        <Nav.drawer current_scope={@current_scope} />
        """)

      assert html =~ "data-phx-theme=\"system\""
      assert html =~ "data-phx-theme=\"light\""
      assert html =~ "data-phx-theme=\"dark\""
    end

    test "renders correct navigation links when authenticated" do
      current_scope = %{user: %{email: "user@test.com"}}
      assigns = %{current_scope: current_scope}

      html =
        rendered_to_string(~H"""
        <Nav.drawer current_scope={@current_scope} />
        """)

      assert html =~ "href=\"/\""
      assert html =~ "href=\"/runs\""
      assert html =~ "href=\"/users/settings\""
      assert html =~ "href=\"/users/log-out\""
    end

    test "renders correct navigation links when not authenticated" do
      assigns = %{current_scope: nil}

      html =
        rendered_to_string(~H"""
        <Nav.drawer current_scope={@current_scope} />
        """)

      assert html =~ "href=\"/users/register\""
      assert html =~ "href=\"/users/log-in\""
    end

    test "renders drawer sidebar structure" do
      assigns = %{current_scope: nil}

      html =
        rendered_to_string(~H"""
        <Nav.drawer current_scope={@current_scope} />
        """)

      assert html =~ "drawer-side"
      assert html =~ "drawer-overlay"
      assert html =~ "bg-base-200"
    end

    test "renders logo and version info" do
      assigns = %{current_scope: nil}

      html =
        rendered_to_string(~H"""
        <Nav.drawer current_scope={@current_scope} />
        """)

      assert html =~ "/images/logo.svg"
      assert html =~ ~r/v\d+\.\d+\.\d+/
    end
  end

  describe "theme_toggle/1" do
    test "renders all theme options" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Nav.theme_toggle />
        """)

      assert html =~ "data-phx-theme=\"system\""
      assert html =~ "data-phx-theme=\"light\""
      assert html =~ "data-phx-theme=\"dark\""
    end

    test "includes phx-click event handlers" do
      assigns = %{}

      html =
        rendered_to_string(~H"""
        <Nav.theme_toggle />
        """)

      assert html =~ "phx-click"
      assert html =~ "phx:set-theme"
    end
  end
end
