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

