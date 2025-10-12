defmodule SimpleElixirServerWeb.RunsLive.Index do
  use SimpleElixirServerWeb, :live_view

  alias SimpleElixirServer.Runs

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.flash_group flash={@flash} />

    <div class="px-4 py-10 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-6xl">
        <div class="flex justify-between items-center mb-8">
          <h1 class="text-3xl font-semibold">Runs</h1>
          <.link patch={~p"/runs/new"} class="btn btn-primary">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-5 w-5 mr-2"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fill-rule="evenodd"
                d="M10 3a1 1 0 011 1v5h5a1 1 0 110 2h-5v5a1 1 0 11-2 0v-5H4a1 1 0 110-2h5V4a1 1 0 011-1z"
                clip-rule="evenodd"
              />
            </svg>
            New Run
          </.link>
        </div>

        <%= if Enum.empty?(@runs) do %>
          <div class="text-center py-12">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="h-16 w-16 mx-auto text-base-content/30 mb-4"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
              />
            </svg>
            <h2 class="text-xl font-medium text-base-content/70 mb-2">No runs yet</h2>
            <p class="text-base-content/50">Get started by creating your first run</p>
          </div>
        <% else %>
          <div class="overflow-x-auto">
            <table class="table table-zebra w-full">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Title</th>
                  <th>Created</th>
                  <th>Outcomes</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                <%= for run <- @runs do %>
                  <tr class="hover">
                    <td class="font-mono text-sm">{run.id}</td>
                    <td class="font-medium">{run.title || "Untitled Run"}</td>
                    <td class="text-sm text-base-content/70">
                      {Calendar.strftime(run.inserted_at, "%b %d, %Y at %I:%M %p")}
                    </td>
                    <td class="text-sm">
                      <%= if run.outcomes do %>
                        <span class="badge badge-sm">{map_size(run.outcomes)} results</span>
                      <% else %>
                        <span class="text-base-content/50">No outcomes</span>
                      <% end %>
                    </td>
                    <td>
                      <.link navigate={~p"/runs/#{run.id}"} class="btn btn-sm btn-ghost">
                        View
                      </.link>
                    </td>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        <% end %>
      </div>
    </div>

    <%= if @show_modal do %>
      <.live_component
        module={SimpleElixirServerWeb.RunsLive.FormComponent}
        id="run-modal"
        current_scope={@current_scope}
      />
    <% end %>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_scope.user.id
    {:ok, runs} = Runs.find_all(%{user_id: user_id})

    socket =
      socket
      |> assign(:runs, runs)
      |> assign(:show_modal, false)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    if socket.assigns.current_scope && socket.assigns.current_scope.user do
      {:noreply, apply_action(socket, socket.assigns.live_action, params)}
    else
      {:noreply,
       socket
       |> put_flash(:error, "You must log in to access this page.")
       |> redirect(to: ~p"/users/log-in")}
    end
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :show_modal, false)
  end

  defp apply_action(socket, :new, _params) do
    assign(socket, :show_modal, true)
  end

  @impl true
  def handle_info({:run_created, _run}, socket) do
    user_id = socket.assigns.current_scope.user.id
    {:ok, runs} = Runs.find_all(%{user_id: user_id})

    socket =
      socket
      |> assign(:runs, runs)
      |> assign(:show_modal, false)
      |> put_flash(:info, "Run created successfully")

    {:noreply, socket}
  end
end
