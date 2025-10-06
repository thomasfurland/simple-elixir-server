## Context
- Ultimate Goal: Implement End to End Event Analysis Engine.
- Tools: Phoenix Live View, Postgresql, Oban.
- Each agent will be given a git worktree to do work in on their own git branches. Agents make changes exclusively within their starting directories.
- Work will be considered complete when the output files and only the output and target files have code representitive of the tasks given to them.
- commit changes with a descriptive and short message and push changes up to remote origin
- If you are unsure ask questions before writing code.

Below are separate objectives for each agent to work on. Agents will only work on their given tasks.

---

## Agent: amp-one
**Scope**
- Setup Oban Pipeline called SimpleJobProcessor for tests and deployments

**Tasks**
- import oban into umbrella mix file
- create new app inside umbrella using the command `mix new`. 
- Setup Oban in config. We use the repo in the SimpleElixirServer app
- generate ecto migration using info found at `https://hexdocs.pm/oban/Oban.Migration.html`
- update release in umbrella mix file to ensure we start oban application as an additional app

**Expected Outputs**
- `amp-one/mix.exs`
- `amp-one/config/config.exs`
- `amp-one/apps/simple_job_processor`
- `amp-one/apps/simple_elixir_server/priv/repo/migrations/timestamp_add_oban.exs`

---

## Agent: amp-two
**Scope**
- create runs table in ecto. we want standard id, foreign key for user id, outcomes as json, nullable title

**Tasks**
- create ecto migration
- create ecto schema file with changeset functions
- create tests for changeset functions

**Expected Outputs**
- `amp-two/apps/simple_elixir_server/priv/repo/migrations/timestamp_add_oban.exs`
- `amp-two/apps/simple_elixir_server/lib/simple_elixir_server/runs/run.ex`
- `amp-two/apps/simple_elixir_server/test/simple_elixir_server/runs_test.exs`


