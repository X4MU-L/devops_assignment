# 14. How would you securely inject secrets into a Kubernetes deployment? Provide an example using Kubernetes Secrets.

Managing secrets in Kubernetes isn’t just about `"storing a password"` — it’s about protecting your application, your cluster, and ultimately your company from critical security breaches.

In this piece, I’ll start simple, then progressively expand into how Kubernetes handles secrets internally, how encryption works, and how to secure them properly using best practices.

Let’s dive in.

## Creating a Kubernetes Secret

**a) Imperatively (One-liner via kubectl)**

You can create a secret imperatively using the kubectl create secret command:

```bash
kubectl create secret generic db-credentials \
  --from-literal=username=admin \
  --from-literal=password=SuperSecret123
```

This will immediately create a Secret object inside Kubernetes, containing the username and password.

**b) Declaratively (YAML Manifests)**

It's better to manage secrets as code using YAML files:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
data:
  username: YWRtaW4=   # "admin" in base64
  password: U3VwZXJTZWNyZXQxMjM=   # "SuperSecret123" in base64
```

**Why Base64?**

Kubernetes Secrets must be valid and safe to transport over the network and store in JSON or YAML.
Base64 ensures the data doesn't break YAML syntax, introduce invalid characters, or become unreadable across systems.

> [!CAUTION]
> Base64 encoding is NOT encryption.
> It’s just encoding. Anyone can decode it trivially.

## How Kubernetes Internally Manages Secrets

When you create a Secret:

It’s sent to the Kubernetes API Server.

The API Server persists it into etcd, the cluster database.

By default, these secrets are only base64-encoded, not encrypted at rest — meaning if someone gets access to etcd, they can read your secrets easily.

**Problem:**

This makes it critical to encrypt your secrets at rest inside etcd.

## Enabling Encryption at Rest (via EncryptionConfiguration)

You can tell Kubernetes API Server to encrypt Secrets before saving them into etcd by providing an EncryptionConfiguration file.

Example configuration:

```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
      - secrets
    providers:
      - kms:   # First try an external KMS provider (like AWS KMS)
          name: myKmsProvider
          endpoint: unix:///tmp/kms.socket
      - aesgcm:   # Fallback to a local symmetric key (AES-GCM)
          keys:
            - name: key1
              secret: pFq3kFJodLRQk3JKe/b5kj2kNjY4e09qRbRQzk7uO9I=  # Base64-encoded AES key
      - identity: {}   # Final fallback: no encryption (only for dev/test!)
```

**Flow:**

- Kubernetes tries encrypting Secrets using KMS first.

- If KMS fails, it uses local AES key encryption (AES-GCM).

- If even AES fails, it falls back to identity (no encryption).

**How AES-GCM Keys Work**

- AES keys are symmetric:
    The same key is used to both encrypt and decrypt.

- The Kubernetes API Server encrypts Secrets using only the first key (e.g., key1).

- It can decrypt Secrets with any key listed in the config.
    (This allows you to rotate keys over time without downtime.)

To explain further, when the api server wants to encrypt a key, it uses the first key in the AES-GCM key config, but when it wants to decrypts it tries each keys in the config till it hits a key that is able to decrypt the encrypted data that it wants to decrypt. The reason for this is for key rotation. Normally when you rotate keys, say every 4-months, usually by moving the original first key to second key, then add a new key..., new data will be encrypted with the new key, but old data will still be encrypted with the old key.

**Key rotation best practice:**
Add key2, make it the first key, remove key1 later once everything is re-encrypted.

**What About the AES Key?**: 
pFq3kFJodLRQk3JKe/b5kj2kNjY4e09qRbRQzk7uO9I=

- It’s a sensitive base64-encoded 256-bit AES key.

- We will never commit this key into Git.

- Store securely (e.g., Vault, AWS Secrets Manager, SSM Parameter Store).

- Ideally, fetch it dynamically (e.g., at bootstrap time via Ansible/Puppet/Chef).

**Example with Ansible:**

- At bootstrap time, your playbook might:

- Fetch the AES key securely.

- Render the EncryptionConfiguration.yaml.

- Start the API server with it mounted.

## How API Server Actually Encrypts Secrets

When the API Server receives a new Secret:

- It base64-decodes the data (plain text now).

- It encrypts the plaintext using the configured key (KMS or AES).

- It stores the ciphertext into etcd.

When reading a Secret:

- It decrypts the stored ciphertext.

- Returns base64-encoded plaintext to the caller (like a Pod or another API client).

The resource (pod) does NOT need the AES key or KMS key!
It trusts the Kubernetes API Server to decrypt for it.

## Controlling Who Can Access Secrets (RBAC)

Secrets are extremely sensitive.
You must control which pods, services, and users who can read them.

Example Role + RoleBinding to restrict Secret access:

```yaml
# Role allowing reading only secrets
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: prod
  name: secret-reader
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
```

```yaml
# Bind a service account to the role
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  namespace: prod
  name: read-secrets
subjects:
- kind: ServiceAccount
  name: app-service-account
roleRef:
  kind: Role
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

Now only the app-service-account can get and list secrets in the prod namespace.

To ensure robust security for sensitive data, it is essential to adopt best practices for secret management. Utilize a reliable secret management solution, such as Vault or AWS KMS, to securely store and manage secrets. Always enable encryption at rest to protect secrets stored in systems like etcd. Implement the Principle of Least Privilege by restricting RBAC access to only those who truly need it. Use network policies to limit pod-to-pod access to secrets, reducing the risk of unauthorized exposure. Regularly audit access to secrets to maintain visibility into who accessed sensitive data and why. Additionally, rotate secrets frequently to minimize the impact of potential leaks. Finally, never log secrets; instead, mask or avoid exposing sensitive environment variables in logs to prevent accidental disclosure.

## Final Thoughts

Kubernetes makes it easy to work with secrets — but securing them properly takes careful planning:

Encrypt secrets at rest.

Store encryption keys securely.

Limit access tightly via RBAC.

Monitor and rotate secrets regularly.

If you build your secrets management like this from the beginning, you'll sleep much better at night.
