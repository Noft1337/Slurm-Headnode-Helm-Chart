# slurm-headnode-helm-chart 📦

A Kubernetes Helm chart to deploy a Slurm headnode, composed of the following subcharts:

* **slurmctld** 🧠
* **slurmdbd** 📊
* **slurmrestd** 🌐
* **slurmd** 🖥️

---

## Configuration ⚙️

This Helm chart supports multiple configurations. The most common use cases are for **production** and **testing** environments.

---

## Production Environment 🚀

In production, Slurm is deployed on a Kubernetes cluster that resides on a **separate network** from the compute nodes.

> ⚠️ **Note**: A known network issue occurs when Slurm is deployed on Kubernetes and compute nodes are external. When `slurmctld` sends an RPC to a `slurmd`, the response is sent to the *container's internal IP*, which is unreachable from external `slurmd` nodes. This may be related to `munge`.

### Required Adjustments 🔧

#### slurmctld 🧠

* Add a `nodeSelector` to pin the pod to a specific node.
* Enable `hostNetwork: true` and set `dnsPolicy: ClusterFirstWithHostNet`.
* Add a `dnsConfig.search` domain matching the compute node environment.
* The `SlurmctldHost` will automatically match the selected node.

#### slurmdbd 📊

* Apply the same settings as `slurmctld`:

  * `nodeSelector`
  * `hostNetwork: true`
  * `dnsPolicy: ClusterFirstWithHostNet`
* Set both `AccountingStorageHost` (in `slurm.conf`) and `DbdHost` (in `slurmdbd.conf`) to the same node.

#### slurmd 🖥️

* Disable the `slurmd` subchart.
* Set the replica count to **0**.

#### Slurm Configuration 🛠️

* Configure `Nodes` and `Partitions` according to production needs.

---

## Testing Environment 🧪

For testing, we use **dynamic slurmd pods** instead of external compute nodes. This avoids the networking issue mentioned above.

However, Slurm components must be correctly resolvable and reachable from within the Kubernetes cluster.

### Required Adjustments 🔧

#### slurmctld 🧠

* Set `setHostnameAsFQDN: true` to use the pod’s fully qualified domain name:

  ```
  <release>-slurmctld-0.<release>-slurmctld.<namespace>.svc.cluster.local
  ```

  * `<release>` is the Helm release name (also used as `ClusterName`).
  * `<namespace>` is the Kubernetes namespace.

* ❌ **Do not set a nodeSelector**.

* The chart will automatically:

  * Set the correct `SlurmctldHost`.
  * Create a **headless service** to make the hostname resolvable.

> 🧑‍💻 **Local clusters (e.g., kind/k3d)** may require setting `storageClass: local-path` for `slurmctld` spool storage.

#### slurmdbd 📊

* Set `setHostnameAsFQDN: true` (results in hostname `<release>-slurmdbd`).
* ❌ **Do not set a nodeSelector**.
* The chart automatically sets:

  * `AccountingStorageHost` in `slurm.conf`
  * `DbdHost` in `slurmdbd.conf`
* A **headless service** is also created for hostname resolution.

#### slurmd 🖥️

* Enable the `slurmd` subchart.
* Set the number of replicas based on test requirements.

#### Slurm Configuration 🛠️

* Define a `Nodeset` with `Feature=k8s`.

* Replace the following plugins (since `cgroup` is not usable):

  | Setting             | Production | Testing                       |
  | ------------------- | ---------- | ----------------------------- |
  | `JobAcctGatherType` | `cgroup`   | `linux`                       |
  | `ProctrackType`     | `cgroup`   | `linuxproc`                   |
  | `TaskPlugin`        | `cgroup`   | `affinity` or remove `cgroup` |

* Set `ignoreSystemd: true` to avoid interfering with local systemd.

---
