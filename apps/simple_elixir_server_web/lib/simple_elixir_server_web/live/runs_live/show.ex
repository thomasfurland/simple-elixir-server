defmodule SimpleElixirServerWeb.RunsLive.Show do
  use SimpleElixirServerWeb, :live_view

  alias SimpleElixirServer.Runs

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <div class="px-4 py-10 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-6xl">
        <div class="mb-8">
          <.link
            navigate={~p"/runs"}
            class="text-sm text-base-content/70 hover:text-base-content mb-4 inline-flex items-center"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-4 w-4 mr-1"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fill-rule="evenodd"
                d="M9.707 16.707a1 1 0 01-1.414 0l-6-6a1 1 0 010-1.414l6-6a1 1 0 011.414 1.414L5.414 9H17a1 1 0 110 2H5.414l4.293 4.293a1 1 0 010 1.414z"
                clip-rule="evenodd"
              />
            </svg>
            Back to Runs
          </.link>
          <h1 class="text-3xl font-semibold">{@run.title || "Untitled Run"}</h1>
        </div>

        <div class="bg-base-200 rounded-lg p-6 mb-6">
          <dl class="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <div>
              <dt class="text-sm font-medium text-base-content/70">Run ID</dt>
              <dd class="mt-1 text-sm font-mono">{@run.id}</dd>
            </div>
            <div>
              <dt class="text-sm font-medium text-base-content/70">Created</dt>
              <dd class="mt-1 text-sm">
                {Calendar.strftime(@run.inserted_at, "%B %d, %Y at %I:%M %p")}
              </dd>
            </div>
            <div>
              <dt class="text-sm font-medium text-base-content/70">Last Updated</dt>
              <dd class="mt-1 text-sm">
                {Calendar.strftime(@run.updated_at, "%B %d, %Y at %I:%M %p")}
              </dd>
            </div>
            <div>
              <dt class="text-sm font-medium text-base-content/70">Owner</dt>
              <dd class="mt-1 text-sm">{@run.user.email}</dd>
            </div>
          </dl>
        </div>

        <div class="bg-base-200 rounded-lg p-6">
          <h2 class="text-xl font-semibold mb-4">Outcomes</h2>
          <%= if @run.outcomes && map_size(@run.outcomes) > 0 do %>
            <div class="overflow-x-auto">
              <pre class="bg-base-300 rounded p-4 text-sm overflow-auto max-h-96"><code>{Jason.encode!(@run.outcomes, pretty: true)}</code></pre>
            </div>
          <% else %>
            <div class="text-center py-8">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-12 w-12 mx-auto text-base-content/30 mb-3"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
                />
              </svg>
              <p class="text-base-content/50">No outcomes available for this run</p>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Runs.find(id) do
      {:ok, run} ->
        {:ok, assign(socket, :run, run)}

      {:error, :not_found} ->
        {:ok,
         socket
         |> put_flash(:error, "Run not found")
         |> redirect(to: ~p"/runs")}
    end
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    if socket.assigns.current_scope && socket.assigns.current_scope.user do
      {:noreply, socket}
    else
      {:noreply,
       socket
       |> put_flash(:error, "You must log in to access this page.")
       |> redirect(to: ~p"/users/log-in")}
    end
  end
end
