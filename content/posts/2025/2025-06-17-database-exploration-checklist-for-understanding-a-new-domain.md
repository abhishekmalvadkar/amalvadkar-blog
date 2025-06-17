---
title: 'Database Exploration Checklist for Understanding a New Domain'
author: Abhishek
type: post
date: 2025-06-17T11:15:23+05:30
url: "/database-exploration-checklist-for-understanding-a-new-domain/"
toc: true
draft: false
categories: [ "SOFTWARE DEVELOPMENT PRACTICES" ]
tags: [ 'domain-understanding' ]
---

A few years ago, I joined a fintech company as a Java backend developer. The team was mid-sprint, the domain was
massive, and there was no up-to-date documentation. On day one, my lead assigned me a bug related to incorrect interest
calculation on a customer’s loan account.

I had no idea what a loan account looked like in their system — no API doc, no domain wiki. So I started digging into
the database. Within a couple of hours, I discovered a `loan_account` table linked to `loan_type`, `interest_schedule`,
and `repayment` tables. Each name told me something new: how interest was defined, how payments were logged, how the
loan matured.

By understanding those tables, I could recreate the business logic in my head — and not only fix the bug, but also write
a better unit test that covered a rare case of floating interest changes mid-tenure.

That experience taught me something invaluable:

> The database is a truth-teller — it captures the real business flow even when documentation doesn't.

Since then, whether it’s onboarding a new domain or debugging a messy issue, my first move has been to explore the
schema, understand table relationships, and write queries to see how the domain behaves with real data.

This guide is a distilled version of what I now follow every time I join a new project or domain-heavy system.

---

## ✅ Database Exploration Checklist for Understanding a New Domain

### 1. Initial Setup

- Connect to the database using DBeaver / IntelliJ / MySQL Workbench.
- Identify the default schema(s) being used.
- List the number of tables in the schema.

### 2. Start with the Core

- Identify the core business table (e.g., order, policy, employee).
- Check the primary key and indexes on the table.
- Note foreign key relationships.

### 3. Explore Relationships

- Trace related tables via foreign keys.
- Identify 1-1, 1-N, and M-N relationships.
- Spot and label join tables (e.g., `user_role_map`, `order_item_map`).

### 4. Identify Master and Reference Tables

- List all static/master tables (e.g., `status`, `type`, `category`).
- Understand their relationship to core tables.
- Look for naming patterns (e.g., `_ref`, `_type`, `_master`).

### 5. Metadata Columns

- Do tables have `created_at`, `updated_at` columns?
- Are soft deletes used (`is_deleted`)?
- Is versioning used (`version` or `rev`)?

### 6. Analyze Data Volumes

- Identify large tables (`SELECT COUNT(*) FROM ...`).
- Understand frequently queried or updated tables.
- Use `EXPLAIN` to analyze index usage on sample queries.

### 7. Historical and Audit Tables

- Check for history or audit tables (e.g., `_history`, `_log`).
- Understand what is tracked and why.
- Trace their relationship with core tables.

### 8. Real Use-Case Analysis

- Pick one common business use case (e.g., "Place Order").
- List all tables involved in that use case.
- Write a sample query that combines them.

### 9. Technical Practices

- Check naming conventions and consistency.
- See if the database uses surrogate keys (`id`) or natural keys.
- Identify triggers, procedures, or events used in the schema.

### 10. Document Everything

- Create a table map with descriptions of each table.
- Keep a set of example queries.
- Maintain a glossary of business terms based on column/table names.

---

## 📊 Guide: Reverse Engineer a Database into ERD

### Tools You Can Use

- **MySQL Workbench**: Good for visual EER diagrams.
- **DBeaver**: Free tool with cross-database support and ER diagrams.
- **SchemaSpy**: Generates HTML-based ERD with detailed info.
- **IntelliJ IDEA (Ultimate)**: Can visualize schema directly from the Database tab.

### Steps in MySQL Workbench

1. Open MySQL Workbench.
2. Go to `Database → Reverse Engineer`.
3. Select your DB connection.
4. Choose your schema and proceed.
5. The tool will generate an EER diagram.
6. You can move tables around and annotate the diagram.

### Steps in DBeaver

1. Connect to your DB in DBeaver.
2. Right-click the schema → `ER Diagram` → `Create new ER diagram`.
3. Select tables to include in the diagram.
4. Automatically generates the relationships.
5. You can export it as an image or PDF.

### Steps in IntelliJ IDEA (Ultimate)

1. Open the Database tool window.
2. Navigate to your schema.
3. Right-click → `Diagrams` → `Show Visualization`.
4. You can zoom, arrange, and export the diagram as needed.

### Best Practices for ERDs

- Only include ~10-15 tables per view for clarity.
- Group core, master, transactional, and log tables separately.
- Add annotations for non-obvious table roles.
- Share the ERD internally for better onboarding and alignment.


