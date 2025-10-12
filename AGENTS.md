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
- Fix duplicate navigation rendering issue across layouts
- Extract navigation into dedicated component file
- Ensure app.html.heex contains nav, root.html.heex remains minimal
- Improve testability by isolating nav component

**Tasks**
- Create dedicated nav component file (e.g., `/apps/simple_elixir_server_web/lib/simple_elixir_server_web/components/nav.ex`)
- Extract all navigation markup from app.html.heex into the new nav component
- Update app.html.heex to call the nav component
- Ensure root.html.heex contains only essential scaffolding (no nav elements)
- Verify nav only renders once during navigation
- Write tests to verify nav component renders correctly and appears only once

**Expected Outputs**
- `/apps/simple_elixir_server_web/lib/simple_elixir_server_web/components/nav.ex`
- `/apps/simple_elixir_server_web/lib/simple_elixir_server_web/components/layouts/app.html.heex`
- `/apps/simple_elixir_server_web/lib/simple_elixir_server_web/components/layouts/root.html.heex`
- `/apps/simple_elixir_server_web/test/simple_elixir_server_web/components/nav_test.exs`

---

## Agent: amp-two
**Scope**
- Ensure authentication is enforced for all LiveView navigation including live_patch
- Prevent logged out users from accessing protected content via handle_params
- Add proper auth checks that aren't bypassed by LiveView navigation

**Tasks**
- Review current on_mount hooks in router live_sessions
- Implement handle_params auth verification for protected LiveViews
- Ensure live_patch routes respect authentication requirements
- Add redirect to login for unauthorized access attempts
- Write tests verifying logged out users cannot access protected routes via live_patch
- Test that navigating via live_patch enforces auth properly

**Expected Outputs**
- Router with proper live_session on_mount hooks
- LiveViews with handle_params auth checks where needed
- Documentation of auth flow for live_patch navigation
- `/apps/simple_elixir_server_web/test/simple_elixir_server_web/live/auth_navigation_test.exs`
