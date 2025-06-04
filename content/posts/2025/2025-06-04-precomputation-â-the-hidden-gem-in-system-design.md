---
title: 'Precomputation: A the Hidden Gem in System Design'
author: Abhishek
type: post
date: 2025-06-04T12:15:22+05:30
url: "/precomputation-a-the-hidden-gem-in-system-design/"
toc: true
draft: false
categories: [ "system design" ]
tags: [ "precomputation", "performance-optimization" ]
---

A couple of years ago, I was building a dashboard for a logistics platform where we needed to show live updates about
shipment statuses, delivery success rates, and agent efficiency metrics.

Initially, the dashboard fetched data in real time using complex aggregation queries across multiple normalized tables
like `shipments`, `delivery_logs`, and `agents`. Everything worked in dev, but once we went live with actual users,
queries started slowing down, response times spiked, and database CPU usage went through the roof.

We realized that although the underlying data was updated every few minutes, our read queries were re-computing the same
values again and again. We changed our approach and decided to **precompute the dashboard data** and store it in a
separate table every few minutes.

The dashboard started responding in under 100ms consistently — no joins, no aggregation, just fast reads. Precomputation
saved the day.

## Problem

Dynamic real-time computations can hurt system performance:

* Aggregation queries over large datasets are slow
* Expensive joins increase DB load
* Recomputing the same values wastes resources
* Caching helps, but needs invalidation logic

In high-read, semi-fresh data use cases like dashboards, reports, recommendations, etc., computing data on demand is
inefficient and brittle.

## Solution

**Precomputation** is a system design strategy where we compute values in advance and store them in a dedicated,
denormalized table to be read directly.

It shifts the workload from read-time to write-time or background processes. This reduces latency, avoids repeated
computation, and enables scale.

## Multiple Examples with Explanation

### 1. Dashboard Metrics Table

* Create a table `dashboard_metrics` updated every 5 minutes
* Fields: total\_shipments\_today, successful\_deliveries, avg\_delivery\_time

Consumers read from this table instead of querying raw data repeatedly.

### 2. Precomputed Report Snapshots

Instead of generating a report on-the-fly:

* Precompute reports hourly or daily
* Store them in a `report_snapshots` table with filters, aggregates
* Expose via API for download/viewing

### 3. Search Suggestion Tables

E-commerce sites precompute trending products, top search terms, and store in dedicated tables refreshed periodically.

**Why?**

* Avoids hitting large tables during each keystroke
* Reduces DB load

### 4. Recommendation Systems

* Precompute product recommendations based on behavior
* Store in a `user_recommendations` table
* Update hourly/daily via batch jobs or ML pipelines

### 5. Analytics Aggregation

* Instead of aggregating logs at query time:
* Use Spark/Flink/Kafka to aggregate and write results to a `daily_metrics` table
* BI tools read directly from this table

### 6. Finance or Billing Systems

* Precompute monthly invoices
* Store in `invoice_summary`
* UI reads invoice totals instantly without calculation

## Best Practices

* Use batch jobs, schedulers (like cron, Quartz) or event-driven pipelines for updates
* Clearly separate computed and raw tables
* Choose appropriate refresh frequency based on business needs
* Use versioning/timestamps for consistency and traceability
* Document data generation logic thoroughly

## Anti Patterns

* Trying to precompute volatile or high-churn data
* Mixing raw and precomputed data in the same table
* Forgetting to update precomputed data (staleness)
* Not monitoring job failures or data quality

## Recommended Book

* **"Building Microservices" by Sam Newman** – Covers patterns around reporting and read-optimized data
* **"Streaming Systems" by Tyler Akidau et al.** – Explains how to compute and materialize views effectively

## Final Thoughts

Precomputing data is a simple but powerful pattern. It offloads expensive operations from user-facing reads and ensures
scalable performance.

Used well, it enables **near real-time dashboards**, **instant reports**, and **predictable performance**, especially in
high-scale systems.

## Summary

```shell
| Use Case           | Precomputed Table Benefit        |
|--------------------|----------------------------------|
| Dashboards         | Instant metrics without joins    |
| Reports            | Fast downloads, predictable load |
| Recommendations    | Pre-warmed UX                    |
| Search Suggestions | Quick autocomplete responses     |
| Invoices           | Faster finance workflows         |
```
> "Don't compute what you can precompute. Read speed is about preparing your answers early."

That's it for today, will meet in next episode.

**Happy coding 😀**
