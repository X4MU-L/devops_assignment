# 15. Given a scenario where you need to scale an application based on CPU usage, explain how you would configure Horizontal Pod Autoscaling in Kubernetes

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

## Understanding Kubernetes Resource Requests and Limits

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

## Why Are Requests and Limits Important?

- **Kubernetes Scheduler uses requests**:
    When scheduling Pods to Nodes, Kubernetes reserves the requested resources on the Node.

    Without requests, Kubernetes assumes 0 resource need.

    The Pod might be scheduled onto an already busy Node.

    Requests = baseline guarantee.

- **Kubernetes enforces limits**
    If your Pod tries to consume more than the limit:

    For CPU: It gets throttled (slowed down).

    For memory: It gets killed if it exceeds the memory limit.

## How Does HPA Use Requests?

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

## Metrics Server: The Backbone of HPA

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

## How to Configure Horizontal Pod Autoscaling (HPA)

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

## Things to Watch Out For

- **No requests set?** HPA won't work properly — CPU utilization will show as 0% or unstable.

- Metrics Server must be installed and healthy.

- Pod startup times matter: If your app is slow to start, aggressive scaling can backfire.

- Memory-based HPA is possible too, but trickier (memory doesn't scale down easily like CPU).

- **Scaling cooldown** exists — Kubernetes doesn't scale every second, usually checks every 15–30 seconds.

## Conclusion

The Horizontal Pod Autoscaler is one of the most powerful, important, and misunderstood features of Kubernetes.

When you deeply understand:

- how requests and limits work,

- how Metrics Server powers HPA,

- how HPA formula decides scaling,

you become a Kubernetes engineer who can truly build reliable, scalable cloud-native applications.

Scaling is not magic — it's math, metrics, and engineering.
