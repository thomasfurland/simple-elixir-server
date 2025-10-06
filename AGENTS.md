## Context
- Ultimate Goal: Implement End to End Event Analysis Engine.
- Tools: Phoenix Live View, Postgresql, Oban.
- Things we have: Oban Pipeline, Runs CRUD, RunsDataStore
- Each agent will be given a git worktree to do work in on their own git branches. Agents make changes exclusively within their starting directories.
- Work will be considered complete when the output files and only the output and target files have code representitive of the tasks given to them.
- Dont run tests locally. This will happen after we push to github where CI takes over.
- commit changes with a descriptive and short message and push changes up to remote origin.
- If you are unsure ask questions before writing code.

Below are separate objectives for each agent to work on. Agents will only work on their given tasks.

---

## Agent: amp-one
**Scope**
- We want a generic implementation for a runs webpage that lists all runs for the user whos logged in, we want to be able to go to a run page when they click on a run as well. So plan for that. We also want a modal that we'll use to create new jobs. Just stub this and the run page. but flesh out the runs page.

**Tasks**
- Create new runs page that displays all runs from a user. find user info from scope in header i believe
- create stub run page that can be clicked to from the list of displayed runs on runs page
- create stub modal for creating new run
- add useful tests for runs page only make sure to use both account and runs fixtures when writing tests
- update router to point to runs page and run page

**Expected Outputs**
- `amp-one/apps/simple_elixir_server_web/lib/simple_elixir_server_web/controllers/run_html/runs.html.heex`
- `amp-one/apps/simple_elixir_server_web/lib/simple_elixir_server_web/controllers/runs_controller.ex`
- `amp-one/apps/simple_elixir_server_web/lib/simple_elixir_server_web/router.ex`
- `amp-one/apps/simple_elixir_server_web/test/simple_elixir_server_web/controllers/runs__controller_test.exs`
- any other files we may need

---

## Agent: amp-two
**Scope**

**Tasks**

**Expected Outputs**

