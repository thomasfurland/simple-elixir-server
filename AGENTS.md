## Context
- Ultimate Goal: deploy Phoenix app to GCP (single VM, Cloud SQL).
- Tools: Terraform (infra), GitHub Actions (CI/CD), eventually ansible.
- Two agents: **infra** + **ci**.
- Each agent will be given a git worktree to do work in on their own git branches. work will be considered complete when the output files and only the output files have code representitive of the tasks given to them.
- never push the changes up to remote origin, stop after commiting changes with a helpful message
- If you are unsure ask questions before writing code.
---

## Agent: Infra
**Scope**
- Terraform GCP setup.

**Tasks**
- VM (Ubuntu, static IP)
- Cloud SQL Postgres
    - database
    - user
- Artifact Registry
- Secret Manager

**Expected Outputs**
- `.infra/terraform/main.tf`
- `.infra/terraform/variables.tf`

---

## Agent: CI
**Scope**
- GitHub Actions on pull request run testing suite.

**Tasks**
- run migrations
- run linter
- run credo
- run test

**Expected Outputs**
- `.github/workflows/CI.yml`

