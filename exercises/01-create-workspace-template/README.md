# Exercise 1: Create "My Java Workspace" in the Dashboard

## Objective

Register a **clickable workspace sample** in the Dev Spaces dashboard called **"My Java Workspace"**. When any team member clicks it, Dev Spaces will spin up a fully provisioned Java development environment — with JDK, Maven, and all required tools — in under 3 minutes.

By the end of this exercise your team will have a one-click tile in the Dev Spaces dashboard that anyone can use to start developing Java immediately.

## What You Will Learn

- What a `devfile.yaml` is and how it defines a workspace environment
- How to register a workspace as a clickable sample in the Dev Spaces dashboard
- How Dev Spaces auto-provisions tools when a workspace starts

---

## Part A: Understand the Devfile

A **devfile** is a YAML file that lives at the root of a Git repository. It tells Dev Spaces what container image to use, what tools to install, and how to configure the environment.

Look at the `devfile.yaml` below. This is what Dev Spaces will use to create workspaces when someone clicks the sample tile.

Create a file called `devfile.yaml`:

```yaml
schemaVersion: 2.2.0
metadata:
  name: my-java-workspace
  version: 1.0.0
  displayName: My Java Workspace
  description: Pre-configured Java development environment with JDK 17, Maven, and essential tools
  language: java
  projectType: Maven
attributes:
  controller.devfile.io/storage-type: per-user

components:
  - name: java-tools
    container:
      image: registry.redhat.io/devspaces/udi-rhel9:3.27
      memoryLimit: 4Gi
      cpuLimit: 1000m
      cpuRequest: 500m
      mountSources: true
      env:
        - name: JAVA_HOME
          value: /usr/lib/jvm/java-17-openjdk
        - name: MAVEN_OPTS
          value: "-Xmx1024m"
        - name: TERM
          value: xterm-256color
      endpoints:
        - name: app
          targetPort: 8080
          exposure: public
          protocol: http
        - name: debug
          targetPort: 5005
          exposure: internal
      volumeMounts:
        - name: m2-cache
          path: /home/user/.m2

  - name: m2-cache
    volume:
      size: 3Gi

commands:
  - id: build
    exec:
      component: java-tools
      commandLine: mvn clean package -DskipTests
      workingDir: ${PROJECT_SOURCE}
      label: "Build (skip tests)"
      group:
        kind: build
        isDefault: true
  - id: test
    exec:
      component: java-tools
      commandLine: mvn test
      workingDir: ${PROJECT_SOURCE}
      label: "Run Tests"
      group:
        kind: test
        isDefault: true
  - id: run
    exec:
      component: java-tools
      commandLine: mvn spring-boot:run
      workingDir: ${PROJECT_SOURCE}
      label: "Run Application"
      group:
        kind: run
        isDefault: true
  - id: debug
    exec:
      component: java-tools
      commandLine: >
        mvn spring-boot:run
        -Dspring-boot.run.jvmArguments="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"
      workingDir: ${PROJECT_SOURCE}
      label: "Debug Application"
      group:
        kind: debug
        isDefault: true

events:
  postStart:
    - build
```

Next, create a `.vscode/` directory with two files to pre-configure extensions and editor settings. Dev Spaces picks these up automatically from the repository.

Create `.vscode/extensions.json`:

```json
{
  "recommendations": [
    "redhat.java",
    "vscjava.vscode-java-debug",
    "vscjava.vscode-java-test",
    "vscjava.vscode-maven",
    "redhat.vscode-xml",
    "redhat.vscode-yaml",
    "dracula-theme.theme-dracula"
  ]
}
```

Create `.vscode/settings.json`:

```json
{
  "workbench.colorTheme": "Solarized Dark",
  "java.configuration.updateBuildConfiguration": "automatic",
  "java.server.launchMode": "Standard",
  "java.compile.nullAnalysis.mode": "automatic",
  "editor.tabSize": 4,
  "editor.detectIndentation": false,
  "files.associations": {
    "*.xml": "xml",
    "*.yaml": "yaml"
  }
}
```

These files ensure that when the workspace starts, the editor will:
- Auto-install the **Red Hat Java** extension (IntelliSense, refactoring, debugging)
- Auto-install the **Java Debug** and **Java Test** extensions
- Auto-install the **Maven for Java** extension (dependency management, build lifecycle)
- Apply the **Solarized Dark** theme (with Dracula available as a recommended extension)
- Enable automatic build configuration updates

> **Note:** These extensions are resolved from the Open VSX registry configured in your Dev Spaces instance. In disconnected environments, the administrator must ensure these extensions are available in the local Open VSX mirror. See [Configure the Open VSX registry URL](https://eclipse.dev/che/docs/stable/administration-guide/configuring-the-open-vsx-registry-url/) for details.

**Key points to discuss with your team:**

| Section | What it does |
|---|---|
| `components[].container.image` | The base container image (Red Hat UDI with JDK, Maven, Git, etc.) |
| `components[].container.env` | Environment variables for Java paths and Maven options |
| `components[].container.endpoints` | Exposes port 8080 (app) and 5005 (debug) |
| `commands[].exec.commandLine` | Build, test, run, and debug commands using Maven |
| `events.postStart` | Triggers the build command on every workspace start |
| `volumes` | Caches Maven dependencies (`.m2`) so re-starts are faster |
| `.vscode/extensions.json` | Auto-installs recommended VS Code extensions (Java, Maven, Debug, XML) |
| `.vscode/settings.json` | Pre-configures the editor: Solarized Dark theme, automatic build updates |

---

## Part B: Push the Devfile to a Git Repository

For the sample tile to work, the `devfile.yaml` must live in a Git repository that Dev Spaces can reach.

**Option 1 — Use the workshop sample repository** (simplest):

The instructor provides the Git URL of the sample Java repository:
```
https://github.com/juanlu-sanz/my-sample-java-app.git
```

**Option 2 — Create a minimal repository** (for teams who want full control):

One team member creates a new repository, adds the `devfile.yaml` from Part A, and pushes it:
```bash
mkdir my-java-workspace && cd my-java-workspace
git init
# (copy the devfile.yaml from Part A into this directory)
git add devfile.yaml
git commit -m "Add Java workspace devfile"
git remote add origin https://<your-git-host>/<org>/my-java-workspace.git
git push -u origin main
```

Take note of the **HTTPS Git URL** — you'll need it in the next step.

> **Note:** The repository must be accessible from the cluster. If it's private, the Dev Spaces dashboard will prompt participants to authenticate with your Git provider (GitHub OAuth, GitLab token, etc.) when they click the tile.

<details>
<summary>✅ Verification: Repository has a devfile</summary>

```bash
# The repo should be accessible and contain devfile.yaml at the root
git ls-remote <your-repo-url> HEAD
```

This should return a commit hash without errors.

</details>

---

## Part C: Register the Sample in the Dashboard

Now create a ConfigMap that tells the Dev Spaces dashboard to show your workspace as a clickable tile.

Create a file called `my-java-workspace-sample.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-java-workspace-sample
  namespace: openshift-devspaces
  labels:
    app.kubernetes.io/part-of: che.eclipse.org
    app.kubernetes.io/component: getting-started-samples
data:
  .sample0: |
    {
      "displayName": "My Java Workspace",
      "description": "Pre-configured Java environment with JDK 17, Maven, and debugging support. Click to start developing!",
      "tags": ["Java", "Maven", "Spring Boot"],
      "url": "https://github.com/<org>/<repo>.git",
      "icon": {
        "base64data": "PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0iI0VFMDAwMCIgZD0iTTEyIDJDNi40OCAyIDIgNi40OCAyIDEyczQuNDggMTAgMTAgMTAgMTAtNC40OCAxMC0xMFMxNy41MiAyIDEyIDJ6bTAgMThjLTQuNDEgMC04LTMuNTktOC04czMuNTktOCA4LTggOCAzLjU5IDggOC0zLjU5IDgtOCA4em0tMi0zLjVsNi0zLjUtNi0zLjV2N3oiLz48L3N2Zz4=",
        "mediatype": "image/svg+xml"
      }
    }
```

**Replace** `https://github.com/<org>/<repo>.git` with your actual repository URL from Part B.

Apply it:

```bash
oc apply -f my-java-workspace-sample.yaml
```

<details>
<summary>✅ Verification: Sample is registered</summary>

```bash
oc get configmap -n openshift-devspaces -l app.kubernetes.io/component=getting-started-samples
```

**Expected:**
```
NAME                       DATA   AGE
my-java-workspace-sample   1      <age>
```

</details>

---

## Part D: Click It!

1. Open the Dev Spaces dashboard:

```bash
oc get route devspaces -n openshift-devspaces -o jsonpath='https://{.spec.host}{"\n"}'
```

2. On the **"Create Workspace"** page, you should see **"My Java Workspace"** as a sample tile with the Java description.

3. Click it. Dev Spaces will:
   - Clone the repository
   - Start a container with the UDI image (includes JDK 17 and Maven)
   - Automatically run the initial build

4. Wait ~2–3 minutes for the workspace to start and the tools to initialize.

5. Open a terminal in the workspace and verify:

```bash
java -version
mvn -version
```

<details>
<summary>✅ Verification: Workspace tools are installed</summary>

Both commands should return version information:

- `java` — confirms JDK 17+ is available
- `mvn` — confirms Maven 3.9+ is available

The tools are pre-installed in the UDI image; no additional installation is needed.

</details>

---

## Discussion

Take 5 minutes to discuss with your team:

1. **One-click onboarding** — New team members can start contributing from day one. No local setup needed.
2. **Version pinning** — The devfile uses the UDI image which bundles JDK 17 and Maven. What happens when the team wants to upgrade to JDK 21?
3. **Customization** — Each team could have their own sample tile. What would you add to yours? (e.g., database tools, Gradle instead of Maven, Quarkus dev mode)

---

## Summary

You have:

1. Learned what a `devfile.yaml` is and how it defines a workspace
2. Registered a clickable sample in the Dev Spaces dashboard
3. Launched a workspace with JDK, Maven, and debugging tools pre-configured
4. Got Red Hat Java and Maven extensions auto-installed with the Solarized Dark theme applied
5. Experienced one-click workspace creation for your team

## Next Exercise

Proceed to [Exercise 2: Team Collaboration](../02-team-collaboration/) to create your own team repository and collaborate on Java code.
