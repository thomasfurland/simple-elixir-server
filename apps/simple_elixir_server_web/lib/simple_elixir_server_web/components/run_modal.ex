defmodule SimpleElixirServerWeb.RunModal do
  use SimpleElixirServerWeb, :live_component

  alias SimpleElixirServer.Runs
  alias SimpleElixirServer.RunDataStore
  alias SimpleJobProcessor.WorkerLookup

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="modal modal-open">
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
            <select name="job_runner" class="select select-bordered w-full" required>
              <option value="">Select a runner</option>
              <%= for queue <- @queues do %>
                <option value={queue}>{prettify_queue_name(queue)}</option>
              <% end %>
            </select>
          </div>

          <div class="form-control mb-4">
            <label class="label">
              <span class="label-text">Candlestick Data (required)</span>
            </label>
            <.live_file_input
              upload={@uploads.candlestick_data}
              class="file-input file-input-bordered w-full"
              required
            />
            <label class="label">
              <span class="label-text-alt">
                CSV file with 4, 5, or 6 columns (OHLC, OHLCV, or timestamp+OHLCV)
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
    queues = WorkerLookup.list_queues()
    {:ok, assign(socket, form: to_form(%{}), queues: queues)}
  end

  defp prettify_queue_name(queue_name) do
    queue_name
    |> String.split("_")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  @impl true
  def handle_event("save", params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :candlestick_data, fn %{path: temp_path}, _entry ->
        case File.read(temp_path) do
          {:ok, csv_content} -> {:ok, csv_content}
          {:error, reason} -> {:postpone, {:file_read_error, reason}}
        end
      end)

    case uploaded_files do
      [csv_content] ->
        case RunDataStore.validate_csv(csv_content) do
          :ok ->
            create_run_with_data(params, socket, csv_content)

          {:error, validation_error} ->
            {:noreply, put_flash(socket, :error, validation_error)}
        end

      [] ->
        {:noreply, put_flash(socket, :error, "Candlestick data file is required")}

      _ ->
        {:noreply, put_flash(socket, :error, "Failed to read uploaded file")}
    end
  end

  defp create_run_with_data(params, socket, csv_content) do
    user_id = socket.assigns.current_scope.user.id
    title = params["title"]
    job_runner = params["job_runner"]

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
        case RunDataStore.write(run.id, csv_content) do
          :ok ->
            case enqueue_job(job_runner, run.id) do
              :ok ->
                send(self(), {:run_created, run})
                {:noreply, socket}

              {:error, error_message} ->
                send(self(), {:put_flash, :error, error_message})
                {:noreply, put_flash(socket, :error, error_message)}
            end

          {:error, reason} ->
            Runs.delete(run)

            {:noreply,
             put_flash(socket, :error, "Failed to save candlestick data: #{inspect(reason)}")}
        end

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp enqueue_job("", _run_id), do: :ok

  defp enqueue_job(queue_name, run_id) do
    case WorkerLookup.queue_to_module(queue_name) do
      {:ok, worker_module} ->
        case Oban.insert(Oban, worker_module.new(%{"run_id" => run_id})) do
          {:ok, _job} -> :ok
          {:error, _changeset} -> {:error, "Failed to enqueue job"}
        end

      {:error, error_message} ->
        {:error, error_message}
    end
  end
end
