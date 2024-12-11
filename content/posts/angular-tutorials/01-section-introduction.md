---
title: "Section Introduction"
author: Abhishek
# images: ["/preview-images/spring-boot-getting-started.webp"]
type: post
draft: false
date: 2024-12-11T00:00:00+00:00
url: /section-introduction
toc: true
categories: ["Angular"]
tags: [Angular, Tutorials]
description: In this Angular tutorial, you will learn what are the key features of Angular, how to create a Angular application and build a functionalities.
---

## Introduction

In this course, we will learn angular from basics to advnaced.
We will start from scratch and we will not focus on new version of angualr features from starting but we will also take them as we go along.

The reason why we are starting from older version of angular is because most of projects are still using angular 9, 10 etc...that's why we will learn those things first and then we will move to new features like standalone component, singals etc..

Let us see if you have newer version means angular 18 is installed but you want to create angular project in older style that means which has NgModule.

## Create Angular Project In Older Style

First check your installed angular version
```txt
E:\FRONT-END-DEVELOPMENT\Angular>ng --version
18.0.7
```

If you create project using angular 18 then it will create based on standalone component i.e it will not have NgModule.

Let's find evidence of this by asking for help to angular.

Ask for help on ng new command
```txt
E:\FRONT-END-DEVELOPMENT\Angular>ng new angular-tutorials --help
```

In output you can see one of parameter called **standalone** with some description which is so meaningfull.
```txt
--standalone          Creates an application based upon the standalone API, without NgModules.                     [boolean] [default: true]
--strict              Creates a workspace with stricter type checking and stricter bundle budgets settings. This setting helps improve
maintainability and catch bugs ahead of time. For more information, see https://angular.dev/tools/cli/template-typecheck#strict-mode [boolean] [default: true]
--style               The file extension or preprocessor to use for style files.           [string] [choices: "css", "scss", "sass", "less"]
--view-encapsulation  The view encapsulation strategy to use in the initial project.     [string] [choices: "Emulated", "None", "ShadowDom"]
```

If you create project like **ng new angular-tutorials** then this **standalone parameter will be true** becuase it has default value true and it will create standalone component based project and if you want to create project based on module then you have to give this parameter value as false while creating project like below

### Good Practice use --dry-run to review command result

```txt
E:\FRONT-END-DEVELOPMENT\Angular>ng new angular-tutorials --standalone false --dry-run
? Which stylesheet format would you like to use? CSS             [ https://developer.mozilla.org/docs/Web/CSS                     ]
? Do you want to enable Server-Side Rendering (SSR) and Static Site Generation (SSG/Prerendering)? No
CREATE angular-tutorials/angular.json (2993 bytes)
CREATE angular-tutorials/package.json (1086 bytes)
CREATE angular-tutorials/README.md (1104 bytes)
CREATE angular-tutorials/tsconfig.json (1054 bytes)
CREATE angular-tutorials/.editorconfig (290 bytes)
CREATE angular-tutorials/.gitignore (629 bytes)
CREATE angular-tutorials/tsconfig.app.json (439 bytes)
CREATE angular-tutorials/tsconfig.spec.json (449 bytes)
CREATE angular-tutorials/.vscode/extensions.json (134 bytes)
CREATE angular-tutorials/.vscode/launch.json (490 bytes)
CREATE angular-tutorials/.vscode/tasks.json (980 bytes)
CREATE angular-tutorials/src/main.ts (256 bytes)
CREATE angular-tutorials/src/index.html (315 bytes)
CREATE angular-tutorials/src/styles.css (81 bytes)
CREATE angular-tutorials/src/app/app-routing.module.ts (255 bytes)
CREATE angular-tutorials/src/app/app.module.ts (411 bytes)
CREATE angular-tutorials/src/app/app.component.html (20239 bytes)
CREATE angular-tutorials/src/app/app.component.spec.ts (1111 bytes)
CREATE angular-tutorials/src/app/app.component.ts (228 bytes)
CREATE angular-tutorials/src/app/app.component.css (0 bytes)
CREATE angular-tutorials/public/favicon.ico (15086 bytes)

NOTE: The "--dry-run" option means no changes were made.
```

You can see, it will create **app.module.ts** file which indiacte that it will create module based project.

Once your command result review is done then remove dry-run parameter and run actual command
which will make pyhsical changes.

```txt
E:\FRONT-END-DEVELOPMENT\Angular>ng new angular-tutorials --standalone false
? Which stylesheet format would you like to use? CSS             [ https://developer.mozilla.org/docs/Web/CSS                     ]
? Do you want to enable Server-Side Rendering (SSR) and Static Site Generation (SSG/Prerendering)? No
CREATE angular-tutorials/angular.json (2993 bytes)
CREATE angular-tutorials/package.json (1086 bytes)
CREATE angular-tutorials/README.md (1104 bytes)
CREATE angular-tutorials/tsconfig.json (1054 bytes)
CREATE angular-tutorials/.editorconfig (290 bytes)
CREATE angular-tutorials/.gitignore (629 bytes)
CREATE angular-tutorials/tsconfig.app.json (439 bytes)
CREATE angular-tutorials/tsconfig.spec.json (449 bytes)
CREATE angular-tutorials/.vscode/extensions.json (134 bytes)
CREATE angular-tutorials/.vscode/launch.json (490 bytes)
CREATE angular-tutorials/.vscode/tasks.json (980 bytes)
CREATE angular-tutorials/src/main.ts (256 bytes)
CREATE angular-tutorials/src/index.html (315 bytes)
CREATE angular-tutorials/src/styles.css (81 bytes)
CREATE angular-tutorials/src/app/app-routing.module.ts (255 bytes)
CREATE angular-tutorials/src/app/app.module.ts (411 bytes)
CREATE angular-tutorials/src/app/app.component.html (20239 bytes)
CREATE angular-tutorials/src/app/app.component.spec.ts (1111 bytes)
CREATE angular-tutorials/src/app/app.component.ts (228 bytes)
CREATE angular-tutorials/src/app/app.component.css (0 bytes)
CREATE angular-tutorials/public/favicon.ico (15086 bytes)
√ Packages installed successfully.
    Successfully initialized git.
```

That's it for today, let's meet in next episode.

Happy coding :grinning:








