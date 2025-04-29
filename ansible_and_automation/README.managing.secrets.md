# 3. Write an Ansible playbook snippet that securely manages secrets and avoids exposing sensitive data in logs or output.

To securely manage secrets in Ansible and avoid exposing sensitive data in logs or output, the best practices involve using Ansible Vault for encrypting sensitive data and controlling the verbosity of output. By using Ansible Vault, you can ensure that your sensitive data (such as passwords, API keys, and other secrets) are encrypted and not visible in the logs or output.

## Steps to Securely Manage Secrets in Ansible:

1. Encrypt sensitive data using Ansible Vault.

2. Use no_log: true for tasks that handle sensitive data, so output is not shown in the logs.

3. Avoid plain-text secrets in playbooks or variables files.

## Example of Managing Secrets in Ansible

1. Encrypting Secrets Using Ansible Vault

  We can encrypt sensitive files, such as passwords or API keys, using Ansible Vault.

  To create an encrypted file, we can use the following command:

  ```bash
  ansible-vault create secrets.yml
  ```

  This will open a text editor where you can add secrets, for example:

  ```yaml
  # secrets.yml

  db_password: "super_secret_password"
  api_key: "12345abcdef"
  ```

  We can also encrypt an existing file using:

  ```bash
  ansible-vault encrypt secrets.yml
  ```

2. Ansible Playbook with Secrets Handling

  Now, let's write an Ansible playbook snippet that loads the encrypted secrets file and ensures sensitive data is not exposed in logs:

  ```yaml
  ---

  - name: Securely manage secrets
    hosts: all
    vars_files: - secrets.yml # Include the encrypted secrets file

    tasks: - name: Set up the database password
    ansible.builtin.shell:
    cmd: "echo '{{ db_password }}' > /etc/myapp/db_password.txt"
    no_log: true # Ensures the password is not logged

        - name: Set up API key for the application
          ansible.builtin.shell:
            cmd: "echo '{{ api_key }}' > /etc/myapp/api_key.txt"
          no_log: true  # Ensures the API key is not logged

        - name: Ensure the application is running
          ansible.builtin.service:
            name: myapp
            state: started
          no_log: true  # Optionally hide the output of tasks that may log sensitive info
  ```

## Breakdown of the Playbook:

- _vars_files_: This loads the encrypted file secrets.yml that contains sensitive data. The file is encrypted using Ansible Vault, and Ansible automatically decrypts it when you run the playbook with the correct Vault password.

- _no_log: true_: This ensures that the sensitive data (like the database password and API key) is not logged in the Ansible output or in the logs. By setting `no_log: true`, Ansible will suppress the output for that particular task, which includes both the result and any data involved.

- _Command Handling_: The database password and API key are stored securely in `/etc/myapp/db_password.txt` and `/etc/myapp/api_key.txt` on the target servers. However, they are not exposed in the logs or output.

## How to Run This Playbook

To run the playbook, we need to provide the Vault password (either interactively or via a password file). Here's how to run it:

If we want to be prompted for the Vault password during the playbook run:

```bash
ansible-playbook --ask-vault-pass playbook.yml
```

Alternatively, if you have a Vault password file, you can provide it with:

```bash
ansible-playbook --vault-password-file .vault_pass playbook.yml
```

## Conclusion

To securely manage secrets in Ansible:

- Use Ansible Vault to encrypt sensitive data.

Use `no_log: true` to ensure sensitive data isn't exposed in logs.

Never store plain-text secrets in playbooks or variables files.

By following these best practices, we can manage secrets securely and avoid exposing sensitive data in our Ansible workflows.