# DevOps Final Assessment Questions

This assessment submission is part of the steps for the completion of the DevOps bootcamp with Developer Foundary.

## Table of Contents

1. [Ansible & Automation](ansible_and_automation/README.md#ansible--automation)
   - [Idempotency in Configuration Management](ansible_and_automation/README.idempotency.configuration.md#1-explain-the-concept-of-idempotency-in-configuration-management-why-is-it-important-and-how-does-the-ansibleposixsysctl-module-help-achieve-it-compared-to-using-ansiblebuiltincommand)
   - [Structuring Ansible Playbooks for Multi-tier Applications](ansible_and_automation/README.playbooks.muilti-teir-application.md#2-given-a-multi-tier-application-describe-how-you-would-structure-your-ansible-playbooks-and-roles-for-maximum-reusability-and-maintainability)
   - [Securely Managing Secrets in Ansible](ansible_and_automation/README.managing.secrets.md#3-write-an-ansible-playbook-snippet-that-securely-manages-secrets-and-avoids-exposing-sensitive-data-in-logs-or-output)
   - [Managing Different Environments with Ansible Inventories](ansible_and_automation/README.managing.inventories.md#4-how-would-you-use-ansible-inventories-to-manage-different-environments-eg-staging-vs-production-provide-an-example)
2. [CI/CD (Jenkins)](cicd_jenkins/README.md#cicd-jenkins)
   - [Jenkins Pipeline Stages for Containerized Applications](cicd_jenkins/README.pipeline.containerization.md#5-describe-the-typical-stages-you-would-include-in-a-jenkins-pipeline-for-a-containerized-application-why-is-each-stage-important)
   - [Managing Environment Variables and Credentials in Jenkins](cicd_jenkins/README.jenkins.environment-variables.md#6-given-a-sample-jenkinsfile-identify-and-explain-how-environment-variables-and-credentials-should-be-managed-securely)
   - [Benefits of Declarative Pipelines in Jenkins](cicd_jenkins/README.declarative.pipeline.md#7-what-are-the-benefits-of-using-declarative-pipelines-in-jenkins-provide-a-simple-example)
3. [Infrastructure as Code (Terraform & Localstack)](infrastructure-as-code/README.md#infrastructure-as-code-terraform--localstack)
   - [Terraform Commands and State File](infrastructure-as-code/README.commands.statefile.md#8-explain-the-purpose-of-terraform-init-plan-and-apply-what-is-the-significance-of-the-state-file)
   - [Localstack for Development and Testing](infrastructure-as-code/README.localstack.md#9-how-does-localstack-help-in-local-development-and-testing-of-cloud-infrastructure-provide-a-scenario-where-it-would-be-especially-useful)
   - [Terraform S3 Bucket with IAM Restrictions](infrastructure-as-code/README.iam.s3.md#10-write-a-terraform-configuration-snippet-to-provision-an-s3-bucket-and-restrict-its-access-to-a-specific-iam-user)
   - [Managing Terraform Modules for Large Projects](infrastructure-as-code/README.modules.md#11-describe-how-you-would-manage-terraform-modules-for-a-large-project-what-are-the-best-practices-for-module-versioning-and-reuse)
4. [Kubernetes & Orchestration](#kubernetes--orchestration)
   - [Kubernetes Resource Types Comparison](#12-explain-the-difference-between-kubernetes-deployments-statefulsets-and-daemonsets-when-would-you-use-each)
   - [Deploying Applications with Helm](#13-describe-the-process-of-deploying-an-application-using-helm-what-are-the-advantages-of-using-helm-charts)
   - [Injecting Secrets into Kubernetes Deployments](#14-how-would-you-securely-inject-secrets-into-a-kubernetes-deployment-provide-an-example-using-kubernetes-secrets)
   - [Horizontal Pod Autoscaling in Kubernetes](#15-given-a-scenario-where-you-need-to-scale-an-application-based-on-cpu-usage-explain-how-you-would-configure-horizontal-pod-autoscaling-in-kubernetes)

## Kubernetes & Orchestration

### 12. Explain the difference between Kubernetes Deployments, StatefulSets, and DaemonSets. When would you use each?

Kubernetes offers several resource types for deploying applications, each designed for specific use cases:

#### Deployments

Deployments are _"Self-healing stateless application manager"_, they can as well be seen as a Load-balanced web servers behind an autoscaler, why `"web Servers"`?, Typically web servers are stateless, and we want to use deployments for only stateless applications - Focused on high availability, scalability, and statelessness. Any replica can serve any request.

- Creates a ReplicaSet to maintain the desired number of Pods.

- Replaces unhealthy Pods automatically — no identity needed.

- Supports rolling updates and rollbacks

- Pods receive random names and IPs when scaled/restarted

- Ideal for applications that scale horizontally.

Example: Scaling a frontend from 3 Pods to 10 in response to traffic., It can be likened to **dynamic compute workers** — any replica can handle any user request.

e.g of yaml file for a Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
```

#### StatefulSet

StatefulSet are like _"Controller for ordered, stateful applications with stable storage"_, Each node has a stable network identity and persistent storage. Order matters during creation, scaling, and updates. Often used for Databases (MySQL, PostgreSQL, MongoDB), Distributed systems (Kafka, ZooKeeper, Elasticsearch), applications requiring stable hostnames, systems needing ordered scaling operations.

- Assigns stable network names (e.g., `mysql-0`, `mysql-1`).

- Binds each Pod to a dedicated `PersistentVolumeClaim` (`PVC`).

- Manages ordered deployment, scaling, and updates.

Example: Scaling a Kafka cluster where `broker-1` cannot just be replaced randomly.

e.g of yaml file for a StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: "postgres"
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:14
        volumeMounts:
        - name: data
          mountPath: /var/lib/postgresql/data
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 10Gi
```

#### DaemonSet

Think opf DaemonSet like _"Cluster-wide service deployment manager"_, it is a system agents installed on every server. It ensures every machine has a necessary background service running, like a metrics collector or a storage agent. It is often used for Monitoring agents (Prometheus Node Exporter), Log collectors (Fluentd, Logstash), Network plugins (Calico, Weave), Storage daemons (Ceph), Node-level services.

- Schedules exactly one `Pod` per `node`.

- Extends automatically when new `nodes` join the `cluster` (Can be configured to run only on nodes matching certain criteria).

- Ensures critical services (log shippers, monitoring agents, node security daemons) run everywhere.

Example: Deploying a Prometheus node exporter on every server.

Think of it like mandatory system agents installed on every machine for consistency.

e.g of yaml file for a DaemonSet

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd
spec:
  selector:
    matchLabels:
      app: fluentd
  template:
    metadata:
      labels:
        app: fluentd
    spec:
      containers:
      - name: fluentd
        image: fluentd:v1.14
```

### 13. Describe the process of deploying an application using Helm. What are the advantages of using Helm charts?

Helm is the package manager for Kubernetes.
It simplifies deploying applications by bundling Kubernetes manifests into versioned, reusable packages called charts.

Deployment Process with Helm

1. **Install Helm**
    Install the Helm CLI on your machine (if not already):

    ```bash
    brew install helm  # macOS
    sudo apt install helm  # Ubuntu
    ```

2. **Add a Helm Repository (or create a custom chart)**

    A repository is like a package index (e.g., Artifact Hub, Bitnami charts):

    ```bash
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
    ```

3. **Install a Chart**

    Use Helm to install a chart into your Kubernetes cluster:

    ```bash
    helm install my-app bitnami/nginx --namespace prod --create-namespace
    ```

    - `my-app` is the release name.
    - `bitnami/nginx` is the chart being installed.

    - `--namespace prod` deploys it into a Kubernetes namespace.

4. **Customize Values**

    To override default chart settings, create a values.yaml file:

    ```yaml
    replicaCount: 3
    service:
    type: LoadBalancer
    ```

    Then install with your custom values:

    ```bash
    helm install my-app bitnami/nginx -f values.yaml
    ```

5. **Upgrade / Rollback**

    Helm tracks revisions automatically:

    ```bash
    helm upgrade my-app bitnami/nginx -f new-values.yaml
    helm rollback my-app 1  # Roll back to revision 1
    ```

6. **Uninstall (Cleanup)**

    To remove the deployment:

    ```bash
    helm uninstall my-app
    ```

#### Advantages of Helm Charts:

- **Templating**: Charts use Go templating to generate Kubernetes manifests, allowing dynamic configuration.

- **Versioning**: Track different versions of your application deployments.

- **Release Management**: Easily upgrade, rollback, or uninstall applications.

- **Reusability**: Share configurations across deployments and environments.

- **Dependency Management**: Automatically install and manage dependencies between charts.

- **Hooks**: Execute tasks at specific points in the release lifecycle.

- **Testing**: Validate charts before deployment with built-in testing capabilities.

- **Community**: Leverage community-maintained charts for common applications.

Helm significantly reduces the complexity of Kubernetes deployments, especially for multi-component applications, while providing tools for managing the entire application lifecycle.

---

### 14. How would you securely inject secrets into a Kubernetes deployment? Provide an example using Kubernetes Secrets.

Managing secrets in Kubernetes isn’t just about `"storing a password"` — it’s about protecting your application, your cluster, and ultimately your company from critical security breaches.

In this piece, I’ll start simple, then progressively expand into how Kubernetes handles secrets internally, how encryption works, and how to secure them properly using best practices.

Let’s dive in.

#### Step 1: Creating a Kubernetes Secret

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

#### Step 2: How Kubernetes Internally Manages Secrets

When you create a Secret:

It’s sent to the Kubernetes API Server.

The API Server persists it into etcd, the cluster database.

By default, these secrets are only base64-encoded, not encrypted at rest — meaning if someone gets access to etcd, they can read your secrets easily.

**Problem:**

This makes it critical to encrypt your secrets at rest inside etcd.

#### Step 3: Enabling Encryption at Rest (via EncryptionConfiguration)

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

#### Step 4: How API Server Actually Encrypts Secrets

When the API Server receives a new Secret:

- It base64-decodes the data (plain text now).

- It encrypts the plaintext using the configured key (KMS or AES).

- It stores the ciphertext into etcd.

When reading a Secret:

- It decrypts the stored ciphertext.

- Returns base64-encoded plaintext to the caller (like a Pod or another API client).

The resource (pod) does NOT need the AES key or KMS key!
It trusts the Kubernetes API Server to decrypt for it.

#### Step 5: Controlling Who Can Access Secrets (RBAC)

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

#### Final Thoughts

Kubernetes makes it easy to work with secrets — but securing them properly takes careful planning:

Encrypt secrets at rest.

Store encryption keys securely.

Limit access tightly via RBAC.

Monitor and rotate secrets regularly.

If you build your secrets management like this from the beginning, you'll sleep much better at night.

### 15. Given a scenario where you need to scale an application based on CPU usage, explain how you would configure Horizontal Pod Autoscaling in Kubernetes

In real-world production environments, most applications/infrastructure rarely experience a constant, predictable workload.

Some days they might sit idle.

Other times they might be flooded with user traffic.

How can your Kubernetes cluster automatically adapt?

The answer is Horizontal Pod Autoscaling (HPA).

In this guide, I'll try to explain:

- Why CPU-based scaling matters

- What requests and limits truly mean

- How the HPA works internally

- How Metrics are collected and used

- Step-by-step setup of an **HPA**

- Best practices you should know


#### Understanding Kubernetes Resource Requests and Limits

Before we can even think about scaling, we must first understand how Kubernetes handles resources.

Inside your Deployment (or StatefulSet, DaemonSet, etc.), we define resource requests and limits for each container, often times, we don't know the use of these - that used to be me:

```yaml
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

Let’s break this down carefully:

| Field |Meaning |
|:----- |:--------- |
| **requests.cpu: 100m**|"This container needs at least 100 millicores (0.1 CPU) to operate normally." |
| **requests.memory: 128Mi** |"This container needs at least 128MiB RAM." |
| **limits.cpu: 500m** | "This container is allowed to consume up to 500 millicores." |
| **limits.memory: 512Mi** |"This container can use up to 512MiB RAM maximum." |

#### Why Are Requests and Limits Important?

- **Kubernetes Scheduler uses requests**:
    When scheduling Pods to Nodes, Kubernetes reserves the requested resources on the Node.

    Without requests, Kubernetes assumes 0 resource need.

    The Pod might be scheduled onto an already busy Node.

    Requests = baseline guarantee.

- **Kubernetes enforces limits**
    If your Pod tries to consume more than the limit:

    For CPU: It gets throttled (slowed down).

    For memory: It gets killed if it exceeds the memory limit.

#### How Does HPA Use Requests?

This is **super important**:

HPA doesn't care about limits at all.

It only looks at CPU usage compared to the request.

e.g:

Suppose we have in a configuration:

- requests.cpu: 100m

- Actual CPU usage: 80m

- Then, utilization = (80m / 100m) × 100% = 80%

Here’s what happens behind the scenes:

1. Kubernetes runs a controller called HorizontalPodAutoscaler controller.

2. The controller periodically polls the Metrics API.

3. It gathers CPU (and optionally memory) utilization of all pods of a target deployment.

4. It calculates the average utilization across all pods.

5. It compares that against your configured target utilization.

6. Using a formula, it decides whether to scale up or scale down:

The formula is approximately:

**desiredReplicas** = **currentReplicas** × ( **current CPU utilization** / **target CPU utilization** )

If current utilization > target → scale up
If current utilization < target → scale down

#### Metrics Server: The Backbone of HPA

Kubernetes does not natively know how much CPU or memory pods are using.

It relies on a component called Metrics Server.

**Metrics Server**:

- Scrapes resource usage data from the Kubelet on each Node.

- Aggregates CPU and memory stats.

- Provides an API (/apis/metrics.k8s.io/) that HPA queries.

> [!IMPORTANT]
> If you don’t have Metrics Server installed and running, HPA won’t work!

You can install Metrics Server using Helm:

```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm install metrics-server metrics-server/metrics-server
```

Or apply a raw manifest:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

#### How to Configure Horizontal Pod Autoscaling (HPA)

Let’s build it properly.

1. Create a Deployment with CPU Requests

    First, define your app Deployment with requests set:

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
    name: my-app
    spec:
    replicas: 2
    selector:
        matchLabels:
        app: my-app
    template:
        metadata:
        labels:
            app: my-app
        spec:
        containers:
        - name: my-app
            image: my-app:latest
            resources:
            requests:
                cpu: 100m
                memory: 128Mi
            limits:
                cpu: 500m
                memory: 512Mi
    ```

   **Why 100m CPU request?**

    - It gives HPA a baseline to measure.

    - 50% usage = using 50m CPU.

2. Create a HorizontalPodAutoscaler (HPA)

    We can imperatively create it for testing:

    ```bash
    kubectl autoscale deployment my-app --cpu-percent=50 --min=2 --max=10
    ```

    Or — better — declaratively create it for production:

    ```yaml
    apiVersion: autoscaling/v2
    kind: HorizontalPodAutoscaler
    metadata:
    name: my-app-hpa
    spec:
    scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: my-app
    minReplicas: 2
    maxReplicas: 10
    metrics:
    - type: Resource
        resource:
        name: cpu
        target:
            type: Utilization
            averageUtilization: 50
    ```

    **This configuration tells Kubernetes:**

    - Keep between 2 and 10 replicas.

    - Scale up or down to maintain ~50% CPU usage based on requests.

SO how does this all come together:

- Let's say we have 4 pods running.

- And CPU usage goes up to 90% (compared to 100m request).

- And from our HPA configuration our target is 50%.

HPA will calculate:

**desiredReplicas** = **4** × ( **90** / **50** ) = **7.2**

HPA will round up to 8 pods.

More pods → workload spread better → less CPU pressure.

#### Things to Watch Out For

- **No requests set?** HPA won't work properly — CPU utilization will show as 0% or unstable.

- Metrics Server must be installed and healthy.

- Pod startup times matter: If your app is slow to start, aggressive scaling can backfire.

- Memory-based HPA is possible too, but trickier (memory doesn't scale down easily like CPU).

- **Scaling cooldown** exists — Kubernetes doesn't scale every second, usually checks every 15–30 seconds.

#### Conclusion

The Horizontal Pod Autoscaler is one of the most powerful, important, and misunderstood features of Kubernetes.

When you deeply understand:

- how requests and limits work,

- how Metrics Server powers HPA,

- how HPA formula decides scaling,

you become a Kubernetes engineer who can truly build reliable, scalable cloud-native applications.

Scaling is not magic — it's math, metrics, and engineering.