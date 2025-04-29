# 2. Given a multi-tier application, describe how you would structure your Ansible playbooks and roles for maximum reusability and maintainability

First, what is a "multi-tier application"?
Perhaps something like:

- **Frontend** (React app, Angular, static HTML)

- **Backend** (Node.js, Go, Python, etc.)

- **Database** (Postgres, MySQL, MongoDB)

- **Services** (Payment service, Email Service, etc)

Each "tier" is a logical layer that might live on different servers (or VMs, containers, etc.).

To structure your Ansible playbooks and roles for maximum reusability and maintainability in a multi-tier application setup (with possibly both static and dynamic inventory), it's essential we follow a clear organization of our inventories, group variables, playbooks, and roles. This approach will allow you to easily manage different environments (like dev, staging, production) while maintaining the flexibility to target dynamic cloud-based infrastructure (like AWS EC2) and static servers.

## Folder structure

I will organize the files so we can easily manage environments (dev, staging, production) and leverage both static and dynamic inventory sources:

```
ansible/
├── inventories/
│   ├── dev/
│   │   ├── hosts.ini            # Static inventory for dev environment
│   │   └── group_vars/
│   │       ├── all.yml          # Common variables for all dev servers
│   │       ├── frontend.yml     # Dev-specific frontend variables
│   │       └── backend.yml      # Dev-specific backend variables
│   ├── staging/
│   │   ├── hosts.ini            # Static inventory for staging environment
│   │   └── group_vars/
│   │       ├── all.yml          # Common variables for all staging servers
│   │       ├── frontend.yml     # Staging-specific frontend variables
│   │       └── backend.yml      # Staging-specific backend variables
│   ├── production/
│   │   ├── hosts.ini            # Static inventory for production environment
│   │   └── group_vars/
│   │       ├── all.yml          # Common variables for all production servers
│   │       ├── frontend.yml     # Production-specific frontend variables
│   │       └── backend.yml      # Production-specific backend variables
│   └── aws_ec2.yml              # Dynamic inventory for AWS EC2 instances
│
├── playbooks/
│   ├── site.yml                 # Main playbook for deployment
│   ├── frontend.yml             # Playbook for frontend-related tasks
│   └── backend.yml              # Playbook for backend-related tasks
│
├── roles/
│   ├── frontend/                # Role for frontend tasks
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── files/
│   ├── backend/                 # Role for backend tasks
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── files/
│   └── common/                  # Common tasks (like installing dependencies, etc.)
│       ├── tasks/
│       ├── templates/
│       └── files/
│
└── ansible.cfg
```

**How the environment-specific structure will work**

- _Inventory selection_ defines which environment you deploy.

- _Group vars_ under each environment define settings like:

  - _DB hostnames_

  - _Backend API URLs_

  - _Secrets, credentials_

  - _Service versions_

**How to Structure the Playbooks and Roles**

- If we have static host

Each environment (dev, staging, production) will have its own static inventory (hosts.ini) and specific group_vars for that environment. We can define different variables for frontend, backend, or all servers in each environment.

Example for `inventories/dev/hosts.ini`:

```ini
[frontend]
dev-frontend-server1 ansible_host=192.168.1.10
dev-frontend-server2 ansible_host=192.168.1.11

[backend]
dev-backend-server1 ansible_host=192.168.1.12
dev-backend-server2 ansible_host=192.168.1.13
```

Example for `inventories/dev/group_vars/frontend.yml`:

```yaml
app_version: "1.0.0"
db_host: "dev-db.example.com"
```

Example for `inventories/dev/group_vars/backend.yml`:

```yaml
app_version: "1.0.0"
api_url: "http://dev-api.example.com"
```

- For our dynamic inventories

When we want to target instances from AWS (or any cloud provider), use a dynamic inventory file (`aws_ec2.yml`) - this is plugin specific, without the file named this was for aws ec2 plugin, it won't work - This will query EC2 instances in real-time, tag them based on their `Role` and `Environment` (or any other tags used in our aws deployment), and automatically group them.

Example for `inventories/aws_ec2.yml`:

```yaml
plugin: amazon.aws.ec2
regions:

- us-east-1
  keyed_groups:
- key: tags['Role']
  prefix: ''
- key: tags['Environment']
  prefix: ''
  filters:
  instance-state-name: running
  hostnames:
- private-ip-address
  compose:
  ansible_host: private_ip_address
```

This will group your EC2 instances based on tags like Role=frontend, Role=backend, Environment=production, etc.

In our playbooks, you can include role-based tasks for different tiers (frontend, backend) and reference them by environment-specific variables. we can also use the --limit flag to target specific environments or roles.

Example for `playbooks/site.yml` (main playbook):

```yaml
---
- name: Deploy to Frontend Servers
  hosts: frontend
  roles:
    - frontend

- name: Deploy to Backend Servers
  hosts: backend
  roles:
    - backend
```

**Running the Playbook for Different Environments**
Now, we can run the playbook depending on the environment or inventory you want to target.

**1. Running Against Static Hosts (for dev, staging, production)**:

_To target the dev environment (using the static inventory `dev/hosts.ini`):_

```bash
ansible-playbook playbooks/site.yml -i inventories/dev/hosts.ini
```

_To target the production environment:_

```bash
ansible-playbook playbooks/site.yml -i inventories/production/hosts.ini
```

_To run it for staging:_

```bash
ansible-playbook playbooks/site.yml -i inventories/staging/hosts.ini
```

**2. Running with Dynamic Inventory (for AWS EC2 instances):**

_When using the dynamic inventory from AWS EC2, we can run the playbook and limit it to only the production servers, for example:_

```bash

ansible-playbook -i inventories/aws_ec2.yml playbooks/site.yml --limit "production"
```

_We can further narrow it down to specific roles (e.g., frontend in production):_

```bash
ansible-playbook -i inventories/aws_ec2.yml playbooks/site.yml --limit "production:frontend"
```

**3. Running for Specific Hosts in Any Inventory:**

_If we want to run it for specific servers or roles, you can combine --limit with hostnames. For example, to run only on the backend servers in production:_

```bash
ansible-playbook -i inventories/aws_ec2.yml playbooks/site.yml --limit "production:backend"
```

## In Summary:

_Inventory_: We were able to organize our environments (dev, staging, production) in separate folders with static (hosts.ini) and dynamic (AWS EC2) inventories.

_Roles_: Structure our roles to manage tasks specific to tiers (frontend, backend) and ensure they are reusable across environments.

_Playbooks_: Use the playbooks to execute roles on different environments, using group-specific variables (group_vars).

_Flexibility_: With `--limit`, we can run playbooks for targeted environments or groups, including both static and dynamic inventories.

This setup is highly flexible and allows you to manage complex multi-tier applications across multiple environments with ease.
