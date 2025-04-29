# 12. Explain the difference between Kubernetes Deployments, StatefulSets, and DaemonSets. When would you use each?

Kubernetes offers several resource types for deploying applications, each designed for specific use cases:

## Deployments

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

## StatefulSet

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

## DaemonSet

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
