[
  plugins: [Phoenix.LiveView.HTMLFormatter],
  inputs: [
    "mix.exs",
    "config/*.exs",
    "apps/*/mix.exs",
    "apps/*/lib/**/*.{ex,exs}",
    "apps/*/test/**/*.{ex,exs}"
  ],
  subdirectories: ["apps/*"]
]
