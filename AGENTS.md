## Context
- Ultimate Goal: Implement End to End Event Analysis Engine.
- Tools: Phoenix Live View, Postgresql, Oban.
- Each agent will be given a git worktree to do work in on their own git branches. Agents make changes exclusively within their starting directories.
- Work will be considered complete when the output files and only the output and target files have code representitive of the tasks given to them.
- Dont run tests locally. This will happen after we push to github where CI takes over.
- commit changes with a descriptive and short message and push changes up to remote origin.
- If you are unsure ask questions before writing code.

Below are separate objectives for each agent to work on. Agents will only work on their given tasks.

---

## Agent: amp-one
**Scope**
- create local store for candle stick data with read and write accessors added. Will be in SimpleElixirServer. This will be used for when people do runs. 
- For reference users will be able to select an oban worker from a dropdown and upload text data to the website in order to "run their job". We will be providing this as local storage and nothing like an S3 bucket so expect small files to be sent not large ones. Keep it simple.

**Tasks**
- Come up with effective naming for filestore and functions
- figure out way to reserve file directory within elixir that will also work in production and survive the build and CD process.
- add useful tests for created functions in test directory

**Expected Outputs**
- `amp-one/apps/simple_elixir_server/lib/simple_elixir_server/xxx.ex`
- `amp-one/apps/simple_elixir_server/test/simple_elixir_server/xxx_test.exs`

---

## Agent: amp-two
**Scope**

**Tasks**

**Expected Outputs**

