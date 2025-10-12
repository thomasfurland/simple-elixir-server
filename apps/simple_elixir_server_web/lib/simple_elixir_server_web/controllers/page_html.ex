defmodule SimpleElixirServerWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use SimpleElixirServerWeb, :html

  alias SimpleElixirServerWeb.Components.Nav

  embed_templates "page_html/*"
end
