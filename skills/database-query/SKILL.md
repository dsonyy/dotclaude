---
name: database-query
description: Directly access SQL databse in local/andbox/staging environemnt
---

Run SQL against Golf Gateway databases using `just` commands.

```bash
# Local (Docker Compose, uses src/db/.env)
just db-query-local "SELECT * FROM config.organizations;"

# Staging (k8s namespace: golf-staging)
just db-query-staging "SELECT * FROM config.organizations;"

# Sandbox (k8s namespace: golf-gateway)
just db-query-sandbox "SELECT * FROM config.organizations;"
```

Remote commands fetch the DB URL from AWS Secrets Manager (`us-east-2`) and run `psql` in an ephemeral `postgres:16-alpine` k8s pod.
Requires AWS CLI and `kubectl` configured for the target cluster.
