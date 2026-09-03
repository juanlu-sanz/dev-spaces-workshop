# Workshop: Java Development on OpenShift Dev Spaces

A hands-on workshop designed for teams interested in developing Java applications inside OpenShift Dev Spaces.

## Workshop Overview

This workshop guides you through two progressive modules:

1. **OpenShift Dev Spaces Setup** — Quick cluster setup + hands-on exercises (workspace templates, team collaboration)
2. **Java Development** — Build, run, and debug Java applications entirely from the cloud

Each module builds on the previous one, culminating in a complete Java development environment running entirely in OpenShift Dev Spaces. Participants work in groups of 2–4 people throughout.

## Environment

| Component | Version |
|---|---|
| OpenShift Container Platform | 4.17+ |
| OpenShift Dev Spaces | 3.19+ |
| JDK | 17+ |
| Maven | 3.9+ |

## Prerequisites

- Access to an OpenShift 4.17+ cluster with cluster-admin privileges
- `oc` CLI installed and configured
- Basic familiarity with containers and Kubernetes concepts
- Basic Java knowledge (helpful but not required)

## Workshop Structure

| Module | Duration | Description |
|---|---|---|
| [Setup](./setup/) | ~20 min | Admin installs Dev Spaces and applies base configuration |
| [Exercise 1: Workspace Template](./exercises/01-create-workspace-template/) | ~30 min | Create "My Java Workspace" template visible in the dashboard |
| [Exercise 2: Team Collaboration](./exercises/02-team-collaboration/) | ~30 min | Work in groups of 2–4 on a shared Java repository |

## Quick Start

1. Start with the [Setup](./setup/) to install OpenShift Dev Spaces on your cluster
2. Progress to [Exercise 1](./exercises/01-create-workspace-template/) to create your Java workspace template
3. Complete [Exercise 2](./exercises/02-team-collaboration/) to collaborate on a Java project

## Repository Map

| Directory | Purpose |
|---|---|
| `setup/` | Dev Spaces setup (admin) — operator installation and cluster configuration |
| `exercises/` | Hands-on exercises for participants (workspace templates, team collaboration) |

## How to Use This Workshop

Each step in every module includes:

- **Objective** — What you will accomplish
- **Instructions** — Step-by-step commands and explanations
- **Expected Output** — What success looks like
- **Verification** — Expandable section to confirm the step completed correctly

### Verification Sections

Throughout this workshop, you will find verification sections formatted as expandable details:

<details>
<summary>✅ Verification: Example Check</summary>

Run this command to verify the step completed successfully:

```bash
oc get pods -n example-namespace
```

**Expected output:**
```
NAME                    READY   STATUS    RESTARTS   AGE
example-pod-abc123      1/1     Running   0          2m
```

If you see this output, proceed to the next step.

</details>

## References

- [OpenShift Dev Spaces Documentation](https://docs.redhat.com/en/documentation/red_hat_openshift_dev_spaces/3.19)
- [OpenShift Container Platform Documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/4.17)
- [Devfile Schema Documentation](https://devfile.io/docs/2.2.0/devfile-schema)
- [Quarkus Documentation](https://quarkus.io/guides/)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)

## License

This workshop content is provided for educational purposes.
