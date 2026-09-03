# Exercise 2: Team Collaboration

## Objective

Work in groups of 2–4 people to simulate a real-world collaboration scenario. Your team will create a shared Git repository, open it in Dev Spaces using the template from Exercise 1, and collaborate on a simple Java project — just like you would in your daily work.

## What You Will Learn

- How to open a Git repository directly in Dev Spaces
- How multiple team members work on the same codebase simultaneously
- How Dev Spaces isolates each developer's workspace while sharing code through Git
- Basic Java development workflow (edit → build → test → commit → push)

---

## Part A: Create a Shared Repository

**One person per team** creates the repository. The rest of the team will be added as collaborators.

### A.1 — Create the repository

Create a new Git repository on your Git hosting service (GitHub, GitLab, Gitea, etc.) with the name:

```
java-team-<team-name>
```

For example: `java-team-alpha`

Initialize it with a README.

### A.2 — Add team members as collaborators

Add all team members with write access to the repository.

### A.3 — Initialize the project structure

Clone the repository locally or in an existing Dev Spaces workspace, then create the base structure:

```bash
git clone https://<your-git-host>/<org>/java-team-<team-name>.git
cd java-team-<team-name>
```

Create the Maven project structure:

```bash
mkdir -p src/main/java/com/workshop/team
mkdir -p src/main/resources
mkdir -p src/test/java/com/workshop/team
```

Create `pom.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.workshop</groupId>
    <artifactId>java-team-project</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>jar</packaging>

    <name>Java Team Project</name>
    <description>Workshop team collaboration project</description>

    <properties>
        <java.version>17</java.version>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <junit.version>5.10.2</junit.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>${junit.version}</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.11.0</version>
                <configuration>
                    <source>${java.version}</source>
                    <target>${java.version}</target>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.2.5</version>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-jar-plugin</artifactId>
                <version>3.3.0</version>
                <configuration>
                    <archive>
                        <manifest>
                            <mainClass>com.workshop.team.App</mainClass>
                        </manifest>
                    </archive>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

Create the main application class `src/main/java/com/workshop/team/App.java`:

```java
package com.workshop.team;

public class App {
    public static void main(String[] args) {
        System.out.println("Hello from Java Team Project!");
        System.out.println("Java version: " + System.getProperty("java.version"));
    }

    public static String greet(String name) {
        return "Hello, " + name + "!";
    }
}
```

Create a test `src/test/java/com/workshop/team/AppTest.java`:

```java
package com.workshop.team;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class AppTest {

    @Test
    void greetReturnsExpectedMessage() {
        assertEquals("Hello, World!", App.greet("World"));
    }

    @Test
    void greetHandlesEmptyName() {
        assertEquals("Hello, !", App.greet(""));
    }
}
```

Create `devfile.yaml` at the root of the repository:

```yaml
schemaVersion: 2.2.0
metadata:
  name: java-team-<team-name>
  version: 1.0.0
  displayName: "Java Team <team-name> Workspace"
  description: "Team workspace for collaborative Java development"
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
      commandLine: java -jar target/*.jar
      workingDir: ${PROJECT_SOURCE}
      label: "Run Application"
      group:
        kind: run
        isDefault: true

events:
  postStart:
    - build
```

> **Note:** When you open this repo from the Dev Spaces dashboard, the dashboard will prompt you to authenticate with your Git provider (GitHub, GitLab, etc.) if the repository is private. This is normal and enables pushing/pulling code from your workspace.

Commit and push:

```bash
git add -A
git commit -m "Initial Java project structure with devfile"
git push origin main
```

<details>
<summary>✅ Verification: Repository is ready</summary>

All team members should be able to see the repository and it should contain:

```
java-team-<team-name>/
├── devfile.yaml
├── pom.xml
└── src/
    ├── main/java/com/workshop/team/App.java
    └── test/java/com/workshop/team/AppTest.java
```

</details>

---

## Part B: Open the Repository in Dev Spaces

**Each team member** opens the repository in their own workspace.

### B.1 — Open via the dashboard

1. Go to the Dev Spaces dashboard.
2. In the **"Import from Git"** field, paste your repository URL:
   ```
   https://<your-git-host>/<org>/java-team-<team-name>.git
   ```
3. Click **"Create & Open"**.

Dev Spaces will detect the `devfile.yaml` in the repository and use it to configure the workspace automatically.

### B.2 — Wait for the workspace to start

The first start takes ~2–3 minutes. The `postStart` event runs `build` which compiles the project and downloads Maven dependencies.

<details>
<summary>✅ Verification: Everyone is in</summary>

Each team member opens a terminal in their workspace and runs:

```bash
java -version
mvn -version
pwd
```

Everyone should see:
- JDK 17+ version output
- Maven 3.9+ version output
- `/projects/java-team-<team-name>` as the working directory

</details>

---

## Part C: Collaborate — Each Member Adds a Class

Now simulate a real team workflow. **Each team member** creates a different utility class on their own branch.

### C.1 — Create a feature branch

Each member creates their own branch:

```bash
git checkout -b feature/<your-name>-util
```

### C.2 — Write a utility class and its test

Each person creates a utility class in `src/main/java/com/workshop/team/` and a matching test. For example:

**Person 1** — `StringUtils.java`:

```java
package com.workshop.team;

public class StringUtils {

    public static String reverse(String input) {
        if (input == null) return null;
        return new StringBuilder(input).reverse().toString();
    }

    public static boolean isPalindrome(String input) {
        if (input == null) return false;
        String cleaned = input.replaceAll("\\s+", "").toLowerCase();
        return cleaned.equals(reverse(cleaned));
    }
}
```

Test — `StringUtilsTest.java`:

```java
package com.workshop.team;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class StringUtilsTest {

    @Test
    void reverseString() {
        assertEquals("olleH", StringUtils.reverse("Hello"));
    }

    @Test
    void detectPalindrome() {
        assertTrue(StringUtils.isPalindrome("racecar"));
        assertFalse(StringUtils.isPalindrome("hello"));
    }

    @Test
    void handleNull() {
        assertNull(StringUtils.reverse(null));
        assertFalse(StringUtils.isPalindrome(null));
    }
}
```

**Person 2** — `MathUtils.java`:

```java
package com.workshop.team;

public class MathUtils {

    public static int factorial(int n) {
        if (n < 0) throw new IllegalArgumentException("Negative input: " + n);
        if (n <= 1) return 1;
        return n * factorial(n - 1);
    }

    public static boolean isPrime(int n) {
        if (n <= 1) return false;
        for (int i = 2; i <= Math.sqrt(n); i++) {
            if (n % i == 0) return false;
        }
        return true;
    }
}
```

Test — `MathUtilsTest.java`:

```java
package com.workshop.team;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class MathUtilsTest {

    @Test
    void factorialOfFive() {
        assertEquals(120, MathUtils.factorial(5));
    }

    @Test
    void factorialOfZero() {
        assertEquals(1, MathUtils.factorial(0));
    }

    @Test
    void primeDetection() {
        assertTrue(MathUtils.isPrime(7));
        assertFalse(MathUtils.isPrime(4));
    }
}
```

**Person 3** — `CollectionUtils.java`:

```java
package com.workshop.team;

import java.util.List;
import java.util.Collections;
import java.util.stream.Collectors;

public class CollectionUtils {

    public static <T extends Comparable<T>> List<T> sorted(List<T> input) {
        if (input == null) return Collections.emptyList();
        return input.stream().sorted().collect(Collectors.toList());
    }

    public static <T> List<T> unique(List<T> input) {
        if (input == null) return Collections.emptyList();
        return input.stream().distinct().collect(Collectors.toList());
    }
}
```

Test — `CollectionUtilsTest.java`:

```java
package com.workshop.team;

import org.junit.jupiter.api.Test;
import java.util.List;
import static org.junit.jupiter.api.Assertions.*;

class CollectionUtilsTest {

    @Test
    void sortsList() {
        assertEquals(List.of(1, 2, 3), CollectionUtils.sorted(List.of(3, 1, 2)));
    }

    @Test
    void removesDuplicates() {
        assertEquals(List.of(1, 2, 3), CollectionUtils.unique(List.of(1, 2, 2, 3, 3)));
    }

    @Test
    void handleNull() {
        assertEquals(List.of(), CollectionUtils.sorted(null));
    }
}
```

### C.3 — Build and test

```bash
mvn test
```

Fix any compilation errors or test failures.

### C.4 — Commit and push your branch

```bash
git add src/
git commit -m "Add <ClassName> utility with tests"
git push origin feature/<your-name>-util
```

<details>
<summary>✅ Verification: Branches pushed</summary>

Each team member should have their branch on the remote:

```bash
git branch -r
```

**Expected:** You should see one branch per team member (plus `origin/main`).

</details>

---

## Part D: Merge and Integrate

### D.1 — Merge branches to main

Each member merges their branch (or creates a pull/merge request, depending on your team's preference):

```bash
git checkout main
git pull origin main
git merge feature/<your-name>-util
git push origin main
```

If there are merge conflicts, resolve them together — this is part of the learning.

### D.2 — Pull the combined result

Once all branches are merged, everyone pulls the final state:

```bash
git checkout main
git pull origin main
```

### D.3 — Build and test the combined project

Verify that everything works together:

```bash
mvn clean test
```

<details>
<summary>✅ Verification: Team project is complete</summary>

```bash
find src -name "*.java" | sort
mvn test
```

**Expected:**
- Multiple Java source files and tests (one utility class + test per team member)
- `mvn test` passes: `BUILD SUCCESS` with all tests green

</details>

---

## Discussion Points

Take 5 minutes as a team to discuss:

1. **Isolation** — Each person had their own workspace, but shared the code via Git. How is this different from sharing a single VM or bastion host?
2. **Reproducibility** — Everyone got the same tools because the `devfile.yaml` defined the environment. What happens if someone on the team needs JDK 21 instead of 17?
3. **Speed** — After the first start, subsequent workspace starts are faster due to Maven caching. What would you customize for your real-world team?

---

## Summary

Your team has successfully:

1. Created a shared Git repository with a Maven project structure
2. Added a `devfile.yaml` that auto-provisions the Java environment
3. Each member opened their own Dev Spaces workspace from the same repo
4. Collaborated using branches (one utility class per person)
5. Merged all contributions, built, and tested the combined result

This mirrors a real-world Java team workflow — isolated environments, shared code, consistent tooling.

## References

- [Devfile Schema Documentation](https://devfile.io/docs/2.2.0/devfile-schema)
- [Red Hat UDI Image](https://catalog.redhat.com/software/containers/devspaces/udi-rhel9/)
- [OpenShift Dev Spaces Documentation](https://docs.redhat.com/en/documentation/red_hat_openshift_dev_spaces/3.19)
