# slurm-headnode-helm-chart

A kubernetes helm chart which deploy's slurm headnode consists the following
subcharts: slurmdbd, slurmctld, slurmrestd.

## Configuration

This helm chart can be deployed with many different configurations, the most
common ones are for production and testing environments.

### Production

In production, slurm is deployed on a Kubernetes cluster that resides in a
different network separated from the compute nodes environment.

There is a network issue when slurm is deployed on
kubernetes with non-kubernetes compute nodes: for a currently yet unknown
reason (but `munge` is suspected), when `slurmctld` sends an RPC to a `slurmd`
instance, it attempts to send its response to the *inner* IP address of the
`slurmctld` - the IP address of the container it resides in, which is
inaccessible for the `slurmd` instance which resides on another cluster, in
another network.

Thus, deploying this chart on the current production environment requires some
specific configuration for the `slurmctld` and `slurmdbd` subcharts.

#### Slurmctld

To solve this, the `slurmctld` pod needs to be accessible to the compute node
network:

The `slurmctld` pod should have `nodeSelector` set to a specific node, with
`network` set to `host` and consequentially `dnsPolicy` set to
`ClusterFirstWithHostNet`. With `nodeSelector` set, the `SlurmctldHost` in
`slurm.conf` will automatically be set to the same node.

Lastly, since the `slurmctld` runs in a different network and most likely also
a different domain/subdomain, and in order to simplify node configuration, it
is recommended to configure a `dnsConfig` with a fitting `search` field in the
`slurmctld` pod specification.

#### Slurmdbd

Similarly, the same issue applies to `slurmdbd`, and to solve it, similar.
configuration needs to be applied here too:

The `slurmdbd` pod should have `nodeSelector` set to a specific node, with
`network` set to `host` and consequentially `dnsPolicy` set to
`ClusterFirstWithHostNet`. Also, the `AccountingStorageHost` in `slurm.conf`
and the `DbdHost` in `slurmdbd.conf` must be set to the same node.

#### Ganesha

To export the configuration files for slurm to the compute environment, the
`NFS` server `ganesha` must be enabled and be configured to have exactly 1
replica.

#### Slurmd

No dynamic `slurmd` instances are required in production so the `slurmd`
subchart should be disabled and configured to have exactly 0 replicas.

#### Slurm config

Nodes and partitions should be configured according to production needs.

### Testing

To test slurm, we do not use bare-metal nodes from the compute environment,
but dynamic `slurmd` instances as pods.

As these instances are within the same Kubernetes cluster as the `slurmctld`,
the network issue mentioned above become obsolete, but another issue arise:

The `slurmctld` must be started on a node (or pod in this case) with its
hostname set to a valid value configured as `SlurmctldHost` in `slurm.conf`,
and similarly the `slurmdbd` must be started on a node with its hostname set
to a valid value configured as `DbdHost` in `slurmdbd.conf`. Also, these hosts
must be resolvable and accessible from the dynamic `slurmd` instances.

Thus different configuration is required.

#### Slurmctld

To configure a valid, fixed hostname for the `slurmctld` instance, the pod's
`setHostnameAsFQDN` setting must be set to `true`. This will cause the hostname
of the `slurmctld` pod to be
`<release>-slurmctld-0.<release>-slurmctld.<namespace>.svc.cluster.local`,
where `<release>` is the name of the release (which is also the `ClusterName`)
and `<namespace>` is the Kubernetes namespace that the helm is installed to.

**No `nodeSelector` configuration should be set**. Without `nodeSelector` set,
the hostname mentioned above will be automatically set as the `SlurmctldHost`.

To allow dynamic `slurmd` instances to resolve this hostname, Kubernetes
should be instructed to create a DNS record for the pod. This is done
automatically by the chart, via creating a *headless* service, in addition to
the *normal* `ClusterIP` service.

When installing the chart on a local cluster (without `iscsi` storage
facilities), the `storageClass` of the spool storage of `slurmctld`
needs to be set to `local-path`.

#### Slurmdbd

Similarly, the `slurmdbd` instance should have *no* `nodeSelector` configured,
as well as its hostname be set to its FQDN by setting `setHostnameAsFQDN` to
`true`. This will result in its hostname to be `<release>-slurmdbd`, and the
chart will automatically set this hostname as the `AccountingStorageHost` in
`slurm.conf` and the `DbdHost` in `slurmdbd.conf`.

There's also an additional `headless` service for this pod, to create a DNS
record for it to be resolvable and accessible from the `slurmd` instances.

#### Ganesha

In most cases, the `ganesha` instance is not required, so it can be disabled
and configured to have exactly 0 replicas, but if needed it can be left as it
is, enabled with 1 replica.

#### Slurmd

The `slurmd` subchart should be enabled, and its numbers of replicas can be
set as required by the test case.

#### Slurm config

A `Nodeset` should be configured with `Feature=k8s`.

Some plugin selection must also be changed:

- `JobAcctGatherType` - `cgroup` plugin cannot be used, use `linux` instead.
- `ProctrackType` - `cgroup` plugin cannot be used, use `linuxproc` instead.
- `TaskPlugin` - `cgroup` plugin cannot be used, use `affinity` instead (some
  configurations include both plugins, simply removing the `cgroup` plugin is
  fine as well).

Similarly, to not interfere with local `systemd` on local machines, local
testing installation requires setting `ignoreSystemd` setting to `true`.
