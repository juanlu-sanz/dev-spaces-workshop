# Setup: Install and Configure Dev Spaces

This section is performed by the **cluster administrator** before the workshop begins. It installs Dev Spaces and applies the base configuration needed for the exercises.

## Prerequisites

- OpenShift 4.17+ cluster with cluster-admin access
- `oc` CLI authenticated to the cluster

---

## Step 1: Install Dev Spaces

```bash
oc create namespace openshift-devspaces
oc apply -f subscription.yaml
```

Wait for the operator to become ready (~2–3 minutes):

```bash
oc get csv -n openshift-operators -w | grep devspaces
```

Once you see `Succeeded`, apply the CheCluster:

```bash
oc apply -f checluster.yaml
```

<details>
<summary>✅ Verification: Dev Spaces is running</summary>

Wait for the cluster to become active (5–10 minutes):

```bash
echo "Waiting for CheCluster to become ready..."
until [ "$(oc get checluster devspaces -n openshift-devspaces -o jsonpath='{.status.chePhase}' 2>/dev/null)" = "Active" ]; do
  sleep 15
  echo "  Still waiting... ($(oc get checluster devspaces -n openshift-devspaces -o jsonpath='{.status.chePhase}' 2>/dev/null || echo 'Initializing'))"
done
echo "✅ CheCluster is Active!"
```

Confirm all pods are running:

```bash
oc get pods -n openshift-devspaces
```

**Expected:** All pods show `Running` or `Completed`.

</details>

---

## Step 2: Apply Security and Resource Configuration

```bash
oc apply -f container-build-scc.yaml
oc apply -f workspace-resource-limits.yaml
```

<details>
<summary>✅ Verification: Configuration applied</summary>

```bash
oc get scc container-build
oc get resourcequota devspaces-workspace-quota -n openshift-devspaces
```

Both commands should return the resource without errors.

</details>

---

## Step 3: Confirm Dashboard Access

Get the dashboard URL and open it in a browser:

```bash
oc get route devspaces -n openshift-devspaces -o jsonpath='https://{.spec.host}{"\n"}'
```

Log in with your OpenShift credentials. You should see the Dev Spaces dashboard with the header banner **"Java Development Workshop Environment"**.

<details>
<summary>✅ Verification: Dashboard responds</summary>

```bash
curl -skI "$(oc get route devspaces -n openshift-devspaces -o jsonpath='https://{.spec.host}')" | head -1
```

**Expected:** `HTTP/2 200` or `HTTP/2 302` (redirect to login).

</details>

---

## (Optional) Step 4: Configure the Extension Registry

By default, Dev Spaces uses an **embedded Open VSX registry** with a limited set of extensions. If your workspace templates reference extensions (via `.vscode/extensions.json` or `.code-workspace` files) that are not included in the embedded registry, you have two options:

**For internet-connected environments** — point Dev Spaces at the public Open VSX registry:

```yaml
spec:
  components:
    pluginRegistry:
      openVSXURL: "https://open-vsx.org"
```

**For air-gapped / disconnected environments** — deploy a standalone Open VSX mirror, populate it with the extensions your teams need (downloading `.vsix` files and publishing them with the `ovsx` CLI), and configure Dev Spaces to use it:

```yaml
spec:
  components:
    pluginRegistry:
      openVSXURL: "https://your-internal-openvsx.example.com"
```

> **Reference:** See the official documentation for full instructions:
> [Configure the Open VSX registry URL — Eclipse Che Administration Guide](https://eclipse.dev/che/docs/stable/administration-guide/configuring-the-open-vsx-registry-url/)

<details>
<summary>✅ Verification: Extensions are available</summary>

After updating the `CheCluster` resource, confirm that the `plugin-registry` pod restarts. Then open a workspace and check the **Extensions** view to verify extensions resolve from the configured registry.

</details>

---

## Setup Complete

The cluster is ready for participants. Share the dashboard URL with the group and proceed to the [Exercises](../exercises/01-create-workspace-template/).

## Files Reference

| File / Reference | Purpose |
|---|---|
| `subscription.yaml` | Operator subscription for Dev Spaces |
| `checluster.yaml` | CheCluster instance with workshop configuration |
| `container-build-scc.yaml` | SCC for container builds |
| `workspace-resource-limits.yaml` | Resource quota for workspace fairness |
| [Configure the Open VSX registry URL](https://eclipse.dev/che/docs/stable/administration-guide/configuring-the-open-vsx-registry-url/) | Official docs for mirroring/changing the extension registry |
