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
- final ticket for this milestone. We still need to implement the candlestick data import in the modal. So the workers have data to process. Candlestick files should be streamed in the usual live view way: 

consume_uploaded_entries(socket, :candlestick_data, fn %{path: temp_path}, _entry ->
  {:ok, csv} = File.read(temp_path)
  RunDataStore.write(run_id, csv)
  {:ok, run_id}
end)

We want to name the file the run id and we want to use the simple_elixir_server.run_data_store to do so.
We want to ensure files are saved with the expected 4,5,6 format so make sure we test for this and provide feedback on the form incase they dont comply. refer to and write in run data store module.

Do we need tests? or is it easy to test? if not we can skip

**Tasks**
- update modal with file dropin labeled candlestick data.
- ensure uploaded file is csv with correct 4, 5, 6 structure. provide feedback if not
- upload csv into the correct directory by using run data store functions.
- add code where necessary
- create tests if it makes sense

**Expected Outputs**
- `/apps/simple_elixir_server_web/lib/simple_elixir_server_web/components/run_modal.ex`
- `/apps/simple_elixir_server/lib/simple_elixir_server/run_data_store.ex`
- any other files we may need

---

## Agent: amp-two
**Scope**
**Tasks**

**Expected Outputs**
