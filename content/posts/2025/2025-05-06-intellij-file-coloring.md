---
title : 'Intellij File Coloring'
author: Abhishek
type: post
date : 2025-05-06T12:13:29+05:30
url: "/intellij-file-coloring/"
toc: true
draft : false
categories: ["Intellij IDEA"]
---


# IntelliJ File Coloring: A Power Feature for Efficient Java Developers

When working with large Java codebases, it’s easy to get overwhelmed by files across modules, test folders, resources, and temporary outputs. IntelliJ IDEA’s **File Coloring** feature provides a visual way to distinguish between file types and scopes — making you a faster and more organized developer.

---

##  Use Cases Where File Coloring Is a Game-Changer

```text
| Scenario                              | Why File Coloring Helps                                                         |
|:--------------------------------------|---------------------------------------------------------------------------------|
| 1. Large Multi-Module Projects 	    | Helps differentiate files from core modules, APIs, services, and tests.         |
| 2. Working with Legacy + New Code     | Color legacy packages to refactor slowly without confusion.                     |
| 3. Rapid Debugging 				    | Easily identify output or temp folders in a sea of files.                       |
| 4. Context Switching 				    | Color UI, backend, test files differently to reduce mental fatigue.             |
| 5. Team Standards 				    | Enforce colors for folders like `generated`, `tests`, `config` for consistency. |
```

---

## Step-by-Step: Setting Up File Coloring in IntelliJ

###  Step 1: Define File Scopes

- Go to: `File > Settings > Appearance & Behavior > Scopes`
- Click `+` to create a new scope. Example:  
  **Name:** `Legacy Code`  
  **Pattern:**
  ```shell
  file:src/legacy//*
  ```

###  Step 2: Assign Colors to Scopes

- Go to: `File > Settings > Appearance & Behavior > File Colors`
- Click `+` to add a new file color.
- Choose:
    - **Scope:** the one you created
    - **Color:** pick any you prefer
    - Enable:
        -  `Use in editor tabs`
        -  `Use in project view`

Repeat for:
- `Tests` (Green)
- `Generated Code` (Gray)
- `Config` (Yellow)
- `UI Layer` (Purple)

###  Step 3: Use Built-in Scopes

Use IntelliJ’s defaults too:
- `Production`
- `Test`
- `Non-Project Files`

Assign colors directly without needing custom rules.

###  Step 4: Result in IDE

You’ll now see:
- Colored files in **Project View**
- Colored **Editor Tabs**
- Colored breadcrumbs and navigation indicators

This gives instant visual feedback while coding.

---

##  Visual Diagram: IntelliJ File Coloring in Action

Below is a representation of how colors help you recognize files quickly:

```text
[Project View]
├── src
│   ├── main [🔵 Blue - Production]
│   │   ├── java
│   │   │   └── com/example/app
│   ├── test [🟢 Green - Tests]
│   │   ├── java
│   │   │   └── com/example/app
├── config [🟡 Yellow - Configuration]
├── legacy [🔴 Red - Legacy Code]
├── generated [⚪ Grey - Generated Code]

[Editor Tabs]
| AppService.java [🔵] | AppServiceTest.java [🟢] | LegacyHelper.java [🔴] |
```

*Diagram: Each folder visually tagged with its own color — like legacy, test, config, etc.*

---

##  How to Share File Coloring Settings in VCS (Git)

To share with your team via Git:

###  Step 1: Version `.idea/scopes` and `.idea/fileColors.xml`

1. Add these paths to Git:

```bash
git add .idea/scopes/
git add .idea/fileColors.xml
```

2. Ensure `.gitignore` doesn't exclude them (edit `.gitignore` if needed).

###  Step 2: Commit and Push

```bash
git commit -m "Add IntelliJ scopes and file color settings"
git push origin main
```

###  Step 3: Team Setup

Other developers will get your file colors as soon as they pull and open the project in IntelliJ. No manual setup needed.

---

##  Architecture Examples — File Coloring in Practice

### 1. Hexagonal / Ports and Adapters
```text
| Layer               | Suggested Color | Scope Pattern           |
|---------------------|-----------------|-------------------------|
| `domain`            | 🟦 Blue         | `file:*/domain//*`      |
| `application`       | 🟩 Green        | `file:*/application//*` |
| `adapters` (UI, DB) | 🟧 Orange       | `file:*/adapter//*`     |
| `config`            | 🟨 Yellow       | `file:*/config//*`      |
```

###  2. Clean Architecture
```text
| Layer                    | Suggested Color | Scope                  |
|--------------------------|-----------------|------------------------|
| `entities`               | 🟦 Blue         | `file:*/entities//*`   |
| `usecases`               | 🟩 Green        | `file:*/usecases//*`   |
| `interfaces/controllers` | 🟪 Purple       | `file:*/interfaces//*` |
```

###  3. Onion Architecture

```text
| Layer                  | Suggested Color | Scope                      |
|------------------------|-----------------|----------------------------|
| `core/domain`          | 🟦 Blue         | `file:*/core/domain//*`    |
| `infrastructure`       | 🟥 Red          | `file:*/infrastructure//*` |
| `application services` | 🟩 Green        | `file:*/application//*`    |
```

###  4. Package-by-Feature

- Feature folders:
    - `feature/user` → 🔵 Blue
    - `feature/order` → 🟢 Green
    - `feature/payment` → 🟣 Purple

Use pattern:
```shell
file:src/main/java/com/example/feature/user//*
```

###  5. Package-by-Layer

```text
| Layer        | Suggested Color | Scope                   |
|--------------|-----------------|-------------------------|
| `controller` | 🟪 Purple       | `file:**/controller//*` |
| `service`    | 🟩 Green        | `file:**/service//*`    |
| `repository` | 🟥 Red          | `file:**/repository//*` |
| `dto`        | 🟦 Blue         | `file:**/dto//*`        |
```

---

## My Initial Step

I have started using Intellij coloring feature on test files, for example I have created Test
Data builder called DiscountBuilder and I have kept it inside test directory, so it should tell
me from file name tab as light green means it's inside test so i will not use this class in production 
code by mistake, this is just short story of mine, but you can discover more usefully this feature in daily life.

## Summary

- IntelliJ File Coloring gives instant context for navigating code.
- Use it to mark test, legacy, config, and generated folders.
- Share your configuration via Git using `.idea/fileColors.xml` and `scopes/`.
- Apply it to common architectures like hexagonal, clean, and onion.
- Increase visual clarity, reduce mistakes, and speed up context switching.

> _“Don’t just read code. Color it smartly.”_

That's it for today, will meet in the next episode.

Happy coding :grinning: