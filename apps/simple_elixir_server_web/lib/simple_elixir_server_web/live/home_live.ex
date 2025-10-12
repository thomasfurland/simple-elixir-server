defmodule SimpleElixirServerWeb.HomeLive do
  use SimpleElixirServerWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center px-4">
      <div class="text-center max-w-2xl">
        <h1 class="text-6xl font-bold mb-4 pb-1 bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">
          Event Analysis Engine
        </h1>
        <p class="text-xl text-base-content/70 mb-12">
          Track, analyze, and optimize your event outcomes
        </p>
        <.link
          navigate={~p"/runs"}
          class="btn btn-primary btn-lg gap-2 shadow-lg hover:shadow-xl transition-all"
        >
          <.icon name="hero-play" class="size-6" /> View Runs
        </.link>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
