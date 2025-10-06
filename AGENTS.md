## Context
- Ultimate Goal: Implement End to End Event Analysis Engine.
- Tools: Phoenix Live View, Postgresql, Oban.
- Things we have: Oban Pipeline, Runs CRUD, RunsDataStore, Entire Runs UI
- Each agent will be given a git worktree to do work in on their own git branches. Agents make changes exclusively within their starting directories.
- Work will be considered complete when the output files and only the output and target files have code representitive of the tasks given to them.
- Dont run tests locally. This will happen after we push to github where CI takes over.
- commit changes with a descriptive and short message and push changes up to remote origin.
- If you are unsure ask questions before writing code.

Below are separate objectives for each agent to work on. Agents will only work on their given tasks.

---

## Agent: amp-one
**Scope**
- we want to tie everything together now and this ticket will be the one to do it. Within the new run modal we want to list out all workers from SimpleJobProcessor.WorkerLookup.list_queues(). When the user submits the form we want to do the queue_to_module lookup and on success enqueue a job with oban. On error we push up the message We want both of the existing stub workers to update the outcome json in runs table to include the __SELF__ that executed the task.

**Tasks**
- update modal drop down to include prettified versions of queue names from SimpleJobProcessor.WorkerLookup.list_queues()
- input the selected option in SimpleJobProcessor.WorkerLookup.queue_to_module/1. Enqeueue on success, push errors up to form on failure
- update both existing workers in SimpleJobProcessor.Workers to update the runs field associated with them to include their name in outcome json.
- do one single integration test for modal where we only check if job was enqueued successfully. Use Oban.Testing module to help

**Expected Outputs**
- `amp-one/apps/simple_elixir_server_web/lib/simple_elixir_server_web/components/run_modal.ex`
- `amp-one/apps/simple_elixir_server_web/test/simple_elixir_server_web/live/runs_live/index_test.exs`
- any other files we may need

---

## Agent: amp-two
**Scope**
**Tasks**

**Expected Outputs**
