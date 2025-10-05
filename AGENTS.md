## Context
- Ultimate Goal: deploy Phoenix app to GCP (single VM, Cloud SQL).
- Tools: Terraform (infra), GitHub Actions (CI/CD), Ansible.
- Each agent will be given a git worktree to do work in on their own git branches. Agents must keep their work exclusively within their starting directories.
- Work will be considered complete when the output files and only the output and target files have code representitive of the tasks given to them.
- commit changes with a descriptive and short message and push changes up to remote origin
- If you are unsure ask questions before writing code.

Below are separate objectives for each agent to work on. Agents will only work on their given tasks.

---

## Agent: amp-one
**Scope**
- Github Action Workflow setup for Ansible files and CD.yml

**Tasks**
- Create Ansible Dynamic Inventory pull of VMs from GCP in ./infra/ansible folder
- Create Ansible Playbook to run deployments for elixir release tarball in gcs in .infra/ansible folder
- Create CD.yml workflow that runs ansible dynamic inventory pull and playbook run in .github/workflows/CD.yml
- refer to .github/workflows/build.yml for information on secret usage and release tarball information

**Expected Outputs**
- `amp-one/.infra/ansible/inventory.yml`
- `amp-one/.infra/ansible/deploy-playbook.yml`
- `amp-one/.github/workflows/CD.yml`

---

## Agent: amp-two
**Scope**
- Github Action Workflow Improvement for CI.yml to get Credo and formatter checks working exclusively on app code and not external library code. this is because it will fail otherwise.

**Tasks**
- create credo config
- create formatter config
- add back credo and formatter checks to CI.yml

**Expected Outputs**
- `amp-two/.github/workflows/CI.yml`
- potentially new credo and formatter config files within the amp-two directory



<!-- phoenix-gen-auth-start -->
## Authentication

- **Always** handle authentication flow at the router level with proper redirects
- **Always** be mindful of where to place routes. `phx.gen.auth` creates multiple router plugs and `live_session` scopes:
  - A plug `:fetch_current_scope_for_user` that is included in the default browser pipeline
  - A plug `:require_authenticated_user` that redirects to the log in page when the user is not authenticated
  - A `live_session :current_user` scope - for routes that need the current user but don't require authentication, similar to `:fetch_current_scope_for_user`
  - A `live_session :require_authenticated_user` scope - for routes that require authentication, similar to the plug with the same name
  - In both cases, a `@current_scope` is assigned to the Plug connection and LiveView socket
  - A plug `redirect_if_user_is_authenticated` that redirects to a default path in case the user is authenticated - useful for a registration page that should only be shown to unauthenticated users
- **Always let the user know in which router scopes, `live_session`, and pipeline you are placing the route, AND SAY WHY**
- `phx.gen.auth` assigns the `current_scope` assign - it **does not assign a `current_user` assign**
- Always pass the assign `current_scope` to context modules as first argument. When performing queries, use `current_scope.user` to filter the query results
- To derive/access `current_user` in templates, **always use the `@current_scope.user`**, never use **`@current_user`** in templates or LiveViews
- **Never** duplicate `live_session` names. A `live_session :current_user` can only be defined __once__ in the router, so all routes for the `live_session :current_user`  must be grouped in a single block
- Anytime you hit `current_scope` errors or the logged in session isn't displaying the right content, **always double check the router and ensure you are using the correct plug and `live_session` as described below**

### Routes that require authentication

LiveViews that require login should **always be placed inside the __existing__ `live_session :require_authenticated_user` block**:

    scope "/", AppWeb do
      pipe_through [:browser, :require_authenticated_user]

      live_session :require_authenticated_user,
        on_mount: [{SimpleElixirServerWeb.UserAuth, :require_authenticated}] do
        # phx.gen.auth generated routes
        live "/users/settings", UserLive.Settings, :edit
        live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
        # our own routes that require logged in user
        live "/", MyLiveThatRequiresAuth, :index
      end
    end

Controller routes must be placed in a scope that sets the `:require_authenticated_user` plug:

    scope "/", AppWeb do
      pipe_through [:browser, :require_authenticated_user]

      get "/", MyControllerThatRequiresAuth, :index
    end

### Routes that work with or without authentication

LiveViews that can work with or without authentication, **always use the __existing__ `:current_user` scope**, ie:

    scope "/", MyAppWeb do
      pipe_through [:browser]

      live_session :current_user,
        on_mount: [{SimpleElixirServerWeb.UserAuth, :mount_current_scope}] do
        # our own routes that work with or without authentication
        live "/", PublicLive
      end
    end

Controllers automatically have the `current_scope` available if they use the `:browser` pipeline.

<!-- phoenix-gen-auth-end -->