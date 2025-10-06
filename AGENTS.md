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
- we want the run modal to be a form that lets us create a run that we write to postgres with ecto. we should expect a title, user_id added behind the scenes from scope and outcomes should be generated for ease of input since when we implement the worker itll do that ourselves. also include a dropdown for job runner field that we will use later, it won't be part of the changeset either. Currently the modal doesn't work on click either so figure out why as well.

**Tasks**
- edit stub modal for creating new run so we actually can create new run. form for title (nullable), outcome generated on click, stored with our existing functions
- add useful tests for modal, within runs_controller_test.ex i assume

**Expected Outputs**
- `amp-one/apps/simple_elixir_server_web/lib/simple_elixir_server_web/controllers/run_html/runs.html.heex`
- `amp-one/apps/simple_elixir_server_web/lib/simple_elixir_server_web/controllers/runs_controller.ex`
- `amp-one/apps/simple_elixir_server_web/lib/simple_elixir_server_web/components/run_modal.ex`
- `amp-one/apps/simple_elixir_server_web/test/simple_elixir_server_web/controllers/runs__controller_test.exs`
- any other files we may need

---

## Agent: amp-two
**Scope**
- create worker lookup module with two functions. 1 takes list of queues from config simple_job_processor, Oban, :queues field and outputs it. 2 takes in a queue name and can regenerate the original module name. We can expect it'll always be in the format SimpleJobProcessor.Workers.QueueName, ensure module exists before we return otherwise we leave a helpful message explaining the correct pattern or ensure its an oban module. This lets us create runners on the fly much quicker since we only need to define the oban module and make sure its registered in the queue. the rest is automated. 
**Tasks**
- create simple oban config in umbrella mix.exs, add 2 queues and create 2 simple oban.worker so we have some examples.
- create worker lookup module that contains the two functions mentioned above.
- write meaningful tests for worker lookup module

**Expected Outputs**
- `amp-two/apps/simple_job_processor/lib/simple_job_processor/worker_lookup.ex` or a better name
- `amp-two/apps/simple_job_processor/lib/simple_job_processor/workers/xxx.ex`
- `amp-two/apps/simple_job_processor/test/simple_job_processor/worker_lookup_test.exs` same name as the module
