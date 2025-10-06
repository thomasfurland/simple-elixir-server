defmodule SimpleElixirServerWeb.RunModal do
  use SimpleElixirServerWeb, :live_component

  alias SimpleElixirServer.Runs

  @impl true
  def render(assigns) do
    ~H"""
    <div class="modal modal-open">
      <div class="modal-box">
        <h3 class="font-bold text-lg mb-4">Create New Run</h3>

        <.form for={@form} id="run-form" phx-target={@myself} phx-submit="save">
          <div class="form-control mb-4">
            <label class="label">
              <span class="label-text">Title</span>
            </label>
            <input
              type="text"
              name="title"
              placeholder="Optional run title"
              class="input input-bordered w-full"
            />
          </div>

          <div class="form-control mb-4">
            <label class="label">
              <span class="label-text">Job Runner</span>
            </label>
            <select name="job_runner" class="select select-bordered w-full">
              <option value="">Select a runner (optional)</option>
              <option value="runner_one">Runner One</option>
              <option value="runner_two">Runner Two</option>
            </select>
            <label class="label">
              <span class="label-text-alt text-base-content/60">
                Runner will be used later in the workflow
              </span>
            </label>
          </div>

          <div class="modal-action">
            <button type="button" class="btn" phx-click="close_modal">Cancel</button>
            <button type="submit" class="btn btn-primary" phx-disable-with="Creating...">
              Create Run
            </button>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  @impl true
  def mount(socket) do
    {:ok, assign(socket, :form, to_form(%{}))}
  end

  @impl true
  def handle_event("save", params, socket) do
    user_id = socket.assigns.current_scope.user.id
    title = params["title"]
    
    outcomes = %{
      "generated_at" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "status" => "pending"
    }

    attrs = %{
      user_id: user_id,
      title: if(title == "", do: nil, else: title),
      outcomes: outcomes
    }

    case Runs.create(attrs) do
      {:ok, run} ->
        send(self(), {:run_created, run})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
