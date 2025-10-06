defmodule SimpleElixirServerWeb.RunModal do
  use SimpleElixirServerWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="modal modal-open">
      <div class="modal-box">
        <h3 class="font-bold text-lg mb-4">Create New Run</h3>
        
        <div class="py-4">
          <p class="text-base-content/70">
            This is a stub modal for creating new runs. 
            Full implementation coming soon.
          </p>
        </div>

        <div class="modal-action">
          <button class="btn" phx-click="close_modal">Cancel</button>
          <button class="btn btn-primary" disabled>Create Run</button>
        </div>
      </div>
    </div>
    """
  end
end
