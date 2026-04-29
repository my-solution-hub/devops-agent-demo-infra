---
inclusion: fileMatch
fileMatchPattern: "**/*.tf,**/*.tfvars"
---

# Infrastructure Documentation Standards

When modifying Terraform files in this project, follow these documentation guidelines to keep docs in sync with code.

## Module READMEs

- When module code changes (adding/removing resources, changing variables or outputs), update the corresponding `README.md` inside that module directory.
- Each module README should document: purpose, inputs (variables), outputs, resources created, and usage examples.
- Keep the inputs and outputs tables in sync with `variables.tf` and `outputs.tf`.

## Architecture Documentation

- When adding or removing AWS resources or modules, update `docs/architecture.md`.
- Update the Mermaid architecture diagram to reflect the current resource topology.
- Ensure the module descriptions section lists all active modules and their responsibilities.

## Resource Tagging

- All resources must include proper tags using `merge(var.tags, { Name = "..." })`.
- The `Name` tag must follow the pattern: `{project_name}-{resource_type}-{identifier}`.
- Common tags (`Environment`, `Project`, `ManagedBy`) are applied via the provider's `default_tags` block and the `var.tags` variable.

## Naming Conventions

- Resource names: `{project_name}-{service}-{component}` (e.g., `aiops-demo-ecs-tasks-sg`).
- Module source paths: `./modules/{service}` for custom modules.
- Variable names: `{service}_{setting}` (e.g., `eks_cluster_version`, `ecs_task_cpu`).
- Output names: `{service}_{attribute}` (e.g., `eks_cluster_endpoint`, `lambda_function_arn`).

## General Rules

- Run `terraform fmt` before committing any `.tf` file changes.
- Run `terraform validate` to confirm configuration is syntactically correct.
- Keep the root `README.md` project structure section up to date when adding new files or directories.
