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
- I want to create a behaviour (using Module) that simplifies and standardizes worker creation for our Event Analysis Engine. This module will inject its own perform method that will expect run_id and filepath to candlestick data (csv file) as inputs. It will then pull in the csv file and iterate it leaving room for a callback that the using module will be expected to generate. This callback will be collecting data while passing it through (think Enum.map), so that an outcome map can be generated. These results will then be taken from the using module where we will then bundle it and push it to the runs table behind the scenes. This module needs to inject basically everything an oban module would need to run, resulting in us just requiring an analzye function from the using module. Please create a basic test worker that uses this behaviour so we can see how it runs and what it outputs. This is for Backtesting strategies qualitatively so keep that in mind. Ask Questions.

**Tasks**
- create behaviour module in worker.ex context file using the description i gave
- create example worker in /workers directory that uses the behaviour and only implements the analyze function.
- create simple test for example worker so we know this behaviour works

**Expected Outputs**
- `/apps/simple_job_processor/lib/simple_job_processor/workers.ex`
- `/apps/simple_job_processor/lib/simple_job_processor/workers/example.ex`
- `/apps/simple_job_processor/test/simple_job_processor/workers/example_test.exs`
- any other files we may need

---

## Agent: amp-two
**Scope**
**Tasks**

**Expected Outputs**
