---
title: 'Architectural Decision Records (ADR): Documenting Decisions That Shape Our Systems'
author: Abhishek
type: post
date: 2025-05-26T12:20:45+05:30
url: "/architectural-decision-records-adr-documenting-decisions-that-shape-our-systems/"
toc: true
draft: false
categories: [ "architecture" ]
tags: [ "adr" ]
---

A few months ago, our development team faced a tricky situation. We had rolled out a new caching strategy using Redis to
improve the performance of a legacy application. Everything seemed perfect—until a newly onboarded developer asked, "Why
are we caching at the service layer and not the repository layer?" Everyone paused. No one remembered the reasoning, and
the original architect had moved on. All we had were vague comments and tribal knowledge. We had made a critical
architectural decision—but never documented *why*.

This led us down a rabbit hole of assumptions, Slack conversations, and git blame spelunking. The outcome? Wasted hours,
inconsistent decisions, and growing frustration. That’s when we discovered the value of **Architectural Decision
Records (ADR)**.

## Problem

Architecture decisions are often made during meetings, discussions, or even ad hoc brainstorming sessions. But without
documentation:

* Decisions become folklore.
* Context behind trade-offs is lost.
* New team members struggle to understand the system.
* Reversing or revisiting decisions becomes difficult.
* Teams repeat mistakes or make contradictory choices.

Architecture shapes the long-term health and evolution of your system. Without traceable records, you risk building on
shaky foundations.

## Solution

**Architectural Decision Records (ADR)** provide a lightweight, structured, and chronological way to document important
architectural decisions. They capture:

* What decision was made
* Why it was made
* What alternatives were considered
* What the consequences are

ADRs make architecture transparent, traceable, and team-friendly. They empower teams to:

* Retain architectural knowledge
* Onboard new developers faster
* Justify trade-offs and reversals
* Stay aligned as the system evolves

## ADR Numbering

Numbering ADRs helps in:

* Keeping a chronological history of decisions
* Making ADRs easy to reference in code reviews or discussions
* Creating a predictable, navigable documentation set

### How to Number ADRs

* Start with `0001`, then `0002`, and so on
* Use a consistent naming format like `0001-use-postgresql.md`
* When decisions are revised, the new ADR gets a new number (e.g., `0020-supersede-postgresql-decision.md`) and references the superseded ADR

This ensures every ADR has a stable identifier and a clear place in your architecture timeline.

### Example ADR Numbering

```shell
| ADR Number | Title                                 | Status     |
| ---------- | ------------------------------------- | ---------- |
| 0001       | Use PostgreSQL for core data          | Accepted   |
| 0002       | Choose Spring Cloud Gateway           | Proposed   |
| 0003       | Use React for admin portal            | Accepted   |
| 0015       | Move to event-driven communication    | Proposed   |
| 0020       | Supersede PostgreSQL with CockroachDB | Superseded |
```
* Each decision gets a number in the order it was created.
* Even deprecated or revised ADRs remain in the list to preserve history.
* Superseded ADRs should link back and forth clearly.

## Multiple Example in Detailed Fashion with Explanation

### Example 1: Choosing a Database

**Title:** Use PostgreSQL over MongoDB for Core User Data

**Status:** Accepted  

**Context:** We need to store user profiles, credentials, preferences, and audit logs. We anticipate relational joins,
consistency, and ACID requirements.

**Decision:** We chose PostgreSQL because:

* Strong ACID compliance
* Better fit for relational joins and normalized data
* Mature support for schema evolution and migrations

**Alternatives Considered:**

* MongoDB: flexible schema but lacks strong ACID guarantees
* MySQL: good option, but team has stronger PostgreSQL expertise

**Consequences:**

* We commit to relational modeling
* May need separate store (like MongoDB) for unstructured data later

### Example 2: API Gateway Strategy

**Title:** Use Spring Cloud Gateway over NGINX for API Routing

**Status:** Proposed

**Context:** We need to route requests to microservices with path-based routing, rate limiting, and simple
authentication.

**Decision:** Use Spring Cloud Gateway

**Why:**

* Deep Spring Boot integration
* Easy to write custom filters
* Reactive and scalable

**Alternatives:**

* NGINX: powerful, but config-heavy and harder to extend

**Consequences:**

* Gateway becomes part of the Java ecosystem
* DevOps must manage it like any other Spring Boot service

### Example 3: Frontend Framework Decision

**Title:** Use React over Angular for Admin Portal

**Context:** The admin portal is mostly CRUD, needs quick iteration, and will be maintained by a small team.

**Decision:** React with functional components and hooks

**Why:**

* Lightweight for the project scope
* More front-end developers on team are experienced in React

**Alternatives:**

* Angular: better for larger, structured apps, but overhead is too high
* Vue: promising, but team lacks experience

**Consequences:**

* Need ESLint, Prettier, and clear coding conventions
* Potential inconsistency with Angular-powered client portal

## Best Practices

* Keep ADRs short and focused—don’t write an essay.
* Use consistent naming: `0001-use-postgresql.md`, `0002-api-gateway-decision.md`
* Start every ADR with a number, title, status, and date
* Review and discuss ADRs as a team
* Store them in version control (e.g., `/docs/adr`)
* Revisit and supersede ADRs when decisions change
* Automate template creation for new ADRs using tools like `adr-tools`
* Link ADRs from code (e.g., service directories) to increase visibility

## Anti Patterns

* Writing ADRs after the fact, just to tick a box
* Mixing minor code decisions with architectural ones
* Storing ADRs in isolated documents outside of version control
* Making ADRs too verbose or too abstract
* Never revisiting or updating old ADRs
* Not involving the team or stakeholders in decisions

## Final Thoughts

ADRs are more than just documentation—they are **conversations made durable**. In fast-moving projects, they bring
structure, transparency, and a shared understanding. Your future teammates (and your future self) will thank you for
taking the time to record *why* something was done.

Start small. Choose one architectural decision from your current project and write your first ADR. Soon, it’ll become
second nature—and your architecture will thank you for it.

## Summary

* Architectural Decision Records (ADRs) are essential for documenting key decisions.
* They help retain knowledge, onboard team members, and guide the future.
* Keep ADRs simple, structured, and collaborative.
* Avoid the trap of writing ADRs just for compliance.
* Make them part of your development workflow.

## Good Quote

> "Architecture is about the important stuff. Whatever that is. And decisions are its building blocks."  
> — Ralph Johnson

That's it for today, will meet in next episode.

Happy coding :grinning:

