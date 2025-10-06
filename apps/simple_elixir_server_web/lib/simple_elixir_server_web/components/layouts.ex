defmodule SimpleElixirServerWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use SimpleElixirServerWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <div class="drawer lg:drawer-open">
      <input id="drawer-toggle" type="checkbox" class="drawer-toggle" />
      <div class="drawer-content flex flex-col">
        <header class="navbar px-4 sm:px-6 lg:px-8 lg:hidden">
          <div class="flex-1">
            <label for="drawer-toggle" class="btn btn-ghost btn-circle">
              <.icon name="hero-bars-3" class="size-6" />
            </label>
          </div>
          <div class="flex-none">
            <.theme_toggle />
          </div>
        </header>

        <main class="px-4 py-8 sm:px-6 lg:px-8">
          <div class="mx-auto max-w-5xl space-y-4">
            {render_slot(@inner_block)}
          </div>
        </main>

        <.flash_group flash={@flash} />
      </div>

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
              <a href="https://phoenixframework.org/" target="_blank">
                <.icon name="hero-globe-alt" class="size-5" /> Website
              </a>
            </li>
            <li>
              <a href="https://github.com/phoenixframework/phoenix" target="_blank">
                <.icon name="hero-code-bracket" class="size-5" /> GitHub
              </a>
            </li>
            <li>
              <a href="https://hexdocs.pm/phoenix/overview.html" target="_blank">
                <.icon name="hero-book-open" class="size-5" /> Get Started
              </a>
            </li>
          </ul>

          <div class="absolute bottom-4 left-4 hidden lg:block">
            <.theme_toggle />
          </div>
        </aside>
      </div>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
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
