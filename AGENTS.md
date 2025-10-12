## Context
- Ultimate Goal: Implement End to End Event Analysis Engine.
- Tools: Phoenix Live View, Postgresql, Oban.
- Things we have: Oban Pipeline, Runs CRUD, RunsDataStore, Entire Runs UI
- Each agent will be given a git worktree to do work in on their own git branches. Agents make changes exclusively within their starting directories.
- Work will be considered complete when the output files and only the output and target files have code representitive of the tasks given to them.
- Run tests locally, but stop execution after explaining what your next step will be. You need my approval to continue.
- commit changes with a descriptive and short message and push changes up to remote origin.
- If you are unsure ask questions before writing code.

Below are separate objectives for each agent to work on. Agents will only work on their given tasks.

---

## Agent: amp-one
**Scope**
- Move RunModal from components directory to live/runs_live directory as form_component.ex
- Refactor to use proper LiveView form component pattern with handle_event callbacks
- Keep all existing functionality (file uploads, validation, job enqueueing) intact
- Component should work with live_patch routing and action-based mounting

**Tasks**
- Create `/apps/simple_elixir_server_web/lib/simple_elixir_server_web/live/runs_live/form_component.ex`
- Move all logic from run_modal.ex to form_component.ex
- Update component to handle :new action properly
- Ensure form state persists during phx-change events
- Delete old run_modal.ex file after migration

**Expected Outputs**
- `/apps/simple_elixir_server_web/lib/simple_elixir_server_web/live/runs_live/form_component.ex`

---

## Agent: amp-two
**Scope**
- Create RunsLive.Show as a proper LiveView to display individual run details
- Replace the dead controller pattern currently in router
- Display run information including title, timestamps, outcomes, and job status
- Should follow same pattern as other LiveViews in the codebase

**Tasks**
- Create show.ex LiveView in runs_live directory
- Implement mount function to load run by ID
- Render run details with proper formatting
- Handle not found cases gracefully
- Follow existing UI/styling patterns from index

**Expected Outputs**
- `/apps/simple_elixir_server_web/lib/simple_elixir_server_web/live/runs_live/show.ex`

---

## Agent: amp-three
**Scope**
- Update router to use proper LiveView routing with actions
- Refactor RunsLive.Index to handle :index and :new actions via live_patch
- Remove phx-click modal toggle pattern in favor of URL-based routing
- Update links to use live_patch instead of regular links

**Note from amp-one:**
- FormComponent reference in index.ex has already been updated to `SimpleElixirServerWeb.RunsLive.FormComponent`
- A minimal `handle_params/3` has been added to index.ex that closes the modal - you need to expand this to properly handle :index and :new actions based on URL params
- The modal currently opens via phx-click="open_create_modal" - you need to replace this with live_patch routing

**Tasks**
- Update router.ex to add live route for /runs/:id with :show action
- Remove dead controller route for runs show
- Expand handle_params/3 in index.ex to handle :new action (currently only closes modal)
- Replace phx-click="open_create_modal" with live_patch to ~p"/runs/new"
- Replace regular link to run details with live_patch
- Remove the old handle_event("open_create_modal") and handle_event("close_modal") handlers after live_patch is working

**Expected Outputs**
- `/apps/simple_elixir_server_web/lib/simple_elixir_server_web/router.ex`
- `/apps/simple_elixir_server_web/lib/simple_elixir_server_web/live/runs_live/index.ex`

---

## Agent: amp-four
**Scope**
- Implement proper validation logic in form_component validate event
- Validate CSV file structure during phx-change before form submission
- Add real-time feedback for form fields (job_runner required, title optional)
- Use changesets properly for form validation state

**Tasks**
- Add proper validation logic to handle_event("validate", ...)
- Validate job_runner is selected before enabling submit
- Add CSV structure validation on file upload change
- Display validation errors in form UI
- Create changeset for run params with proper validation rules

**Expected Outputs**
- `/apps/simple_elixir_server_web/lib/simple_elixir_server_web/live/runs_live/form_component.ex`
