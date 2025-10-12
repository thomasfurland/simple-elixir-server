defmodule SimpleElixirServerWeb.Components.Nav do
  @moduledoc """
  Navigation component for the application.
  Renders a drawer sidebar with navigation links based on authentication state.
  """
  use SimpleElixirServerWeb, :html

  @doc """
  Renders the navigation drawer with menu items.

  ## Attributes
    * `current_scope` - The current scope containing user information. When nil, shows auth links.

  ## Examples

      <Nav.drawer current_scope={@current_scope} />
  """
  attr :current_scope, :map, default: nil, doc: "the current scope with user info"

  def drawer(assigns) do
    ~H"""
    <div class="drawer-side">
      <label for="drawer-toggle" aria-label="close sidebar" class="drawer-overlay"></label>
      <aside class="bg-base-200 min-h-full w-64 p-4">
        <div class="mb-8">
          <a href="/" class="flex items-center gap-2">
            <img src={~p"/images/logo.svg"} width="36" />
            <span class="text-sm font-semibold">v{Application.spec(:phoenix, :vsn)}</span>
          </a>
        </div>

        <ul class="menu space-y-2">
          <%= if @current_scope do %>
            <li>
              <a class="pointer-events-none">
                <.icon name="hero-user" class="size-5" />
                {@current_scope.user.email}
              </a>
            </li>
            <li>
              <a href={~p"/"}>
                <.icon name="hero-home" class="size-5" /> Home
              </a>
            </li>
            <li>
              <a href={~p"/runs"}>
                <.icon name="hero-play" class="size-5" /> Runs
              </a>
            </li>
            <li>
              <a href={~p"/users/settings"}>
                <.icon name="hero-cog-6-tooth" class="size-5" /> Settings
              </a>
            </li>
            <li>
              <a href={~p"/users/log-out"} data-method="delete">
                <.icon name="hero-arrow-right-on-rectangle" class="size-5" /> Log out
              </a>
            </li>
          <% else %>
            <li>
              <a href={~p"/users/register"}>
                <.icon name="hero-user-plus" class="size-5" /> Register
              </a>
            </li>
            <li>
              <a href={~p"/users/log-in"}>
                <.icon name="hero-arrow-left-on-rectangle" class="size-5" /> Log in
              </a>
            </li>
          <% end %>
        </ul>

        <div class="absolute bottom-4 left-4 hidden lg:block">
          <.theme_toggle />
        </div>
      </aside>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
