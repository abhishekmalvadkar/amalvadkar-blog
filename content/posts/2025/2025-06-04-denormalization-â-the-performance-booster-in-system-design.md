---
title: 'Denormalization: A the Performance Booster in System Design'
author: Abhishek
type: post
date: 2025-06-04T12:04:14+05:30
url: "/denormalization-a-the-performance-booster-in-system-design/"
toc: true
draft: false
categories: [ "system design" ]
tags: [ "denormalization", "performance-optimization" ]
---

A few years back, I was working on a real-time analytics dashboard for a SaaS product. The application involved complex
joins across multiple tables to generate metrics like active users, feature usage trends, and retention curves.

During our staging load test, the API that aggregated metrics across 6 normalized tables started timing out. We
optimized indexes, tweaked queries, even added replicas, but the latency was still not acceptable.

One of our senior architects walked in, looked at our data model, and asked a simple question:
**"Why are we not denormalizing this?"**

We restructured some tables, precomputed aggregates, and flattened certain entities. The result? Queries that took **5
seconds dropped to under 100 ms**.

## Problem

In highly normalized schemas:

* Reads often require multiple joins
* Complex queries become slow as data grows
* Real-time aggregations are hard
* Caching becomes less effective
* Schema flexibility suffers in large-scale applications

This structure is great for consistency and avoiding redundancy, but comes at the cost of **read performance and
scalability**.

## Solution

**Denormalization** is a deliberate design choice in system design where we duplicate data or precompute values to
optimize for:

* Faster reads
* Simpler queries
* Lower join costs
* Easier horizontal scaling

It doesn't replace normalization but complements it when speed, scale, or developer productivity is a priority.

## Multiple Examples with Explanation

### 1. User Profile Aggregation

**Normalized Design:**

* `users`, `addresses`, `preferences`, `roles` tables

**Query:** Requires 3–4 joins just to render a profile page.

**Denormalized Version:** Embed address and roles into a single `user_profile` table or document (in MongoDB or
Elastic).

**Result:**

* Simpler query
* Faster response time

### 2. Product Catalog and Category Info

**Normalized:** Products reference category\_id

**Denormalized:** Store category name and description in product table

**Why?**

* Category name rarely changes
* Avoids join per query

### 3. Analytics and Reporting

**Scenario:** Daily summary of user actions

**Problem:** Joins across billions of records in real-time

**Solution:**

* Precompute daily aggregates and store in `daily_summary` table
* Ingest denormalized rows into warehouse (e.g., BigQuery or Redshift)

### 4. Search Optimization

In Elasticsearch, you typically denormalize your data:

* Product includes brand, price, category, ratings — all as a flat document

Why?

* Join is not supported
* Flat structure is optimized for indexing and retrieval

### 5. Event-Driven Systems (CQRS)

In Command Query Responsibility Segregation:

* Writes go to normalized models
* Reads use denormalized projections

**Example:**

* Order write model: normalized tables
* Order read model: precomputed flat table with user name, items, total

## Best Practices

* Denormalize only where reads dominate writes
* Use materialized views or background jobs to maintain denormalized data
* Monitor consistency — stale data can be misleading
* Document clearly where denormalization is applied
* Use denormalized data as read-only whenever possible

## Anti Patterns

* Denormalizing too early in design (premature optimization)
* Blindly duplicating data without update strategies
* Using denormalized writes for transactional workflows
* Failing to monitor or audit stale or inconsistent data

## Recommended Book

* **"Designing Data-Intensive Applications" by Martin Kleppmann** – Great treatment of denormalization in CQRS, event
  sourcing, and data modeling.
* **"NoSQL Distilled" by Pramod Sadalage and Martin Fowler** – Helps understand trade-offs in schema design.

## Final Thoughts

Denormalization is a tool, not a silver bullet. It enables **speed, scale, and simplified querying** — but with
trade-offs in consistency and write complexity.

Use it deliberately, communicate it clearly across teams, and maintain it carefully. Done right, it can unlock massive
performance improvements in modern systems.

## Summary

```shell
| Use Case             | Denormalization Benefit    |
|----------------------|----------------------------|
| Profile Page         | Avoids multiple joins      |
| Product Listing      | Faster category display    |
| Analytics Dashboards | Precomputed metrics        |
| Search Engine        | Flat document model        |
| CQRS Read Models     | Simplified read projection |
```
> "Normalize until it hurts, denormalize until it works."
> — Michael Blaha

That's it for today, will meet in next episode.

**Happy coding 😀**
