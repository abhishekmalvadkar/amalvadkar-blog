---
title: 'Mastering Domain Understanding Through Database Schema: A Developer Deep Dive'
author: Abhishek
type: post
date: 2025-06-17T11:34:50+05:30
url: "/mastering-domain-understanding-through-database-schema-a-developer's-deep-dive/"
toc: true
draft: false
categories: [ "SOFTWARE DEVELOPMENT PRACTICES" ]
tags: [ 'domain-understanding' ]
---

On my first week at a new job, I was assigned to a legacy HRMS system and asked a seemingly simple question:

> "Can you show each employee's leave balance for this quarter?"

I nodded confidently but deep down, I was stuck. There was no documentation, no diagrams, and the person who had built
the leave module had left the company.
I asked around — no one really knew how leave balance was calculated. Some said it was stored, others said it was
calculated on the fly.

So, I opened the database.

I found a table called `leave_allocation`. Another called `leave_request`. Then there was `leave_type`, `employee`, and
even `holiday_master`.
By joining them, inspecting actual data, and running test queries, I slowly pieced together the domain logic.
I learned that:

* Leave balance wasn't stored — it was **calculated from allocation minus approved leave requests**.
* Public holidays were excluded using `holiday_master`.
* Some employees had different leave types configured.

By the end of the week, I not only gave the correct leave balance — I created a reusable SQL view for it, documented the
logic, and became the "go-to person" for all leave-related queries.

That incident changed how I looked at backend systems.

> Since then, I’ve realized that **databases don’t just store data — they reveal how the business truly works**.
> If you know how to explore a schema, you can understand the entire domain — even when everything else is missing.

This blog is a practical guide to doing exactly that — with real-world techniques and use cases.

Let’s dive in.

## 🧪 Use Case 1: “Show employee leave balance in HRMS system”

### 🔍 Step-by-step Domain Understanding via DB

**Step 1: Identify the main action or goal**

> Show leave balance — that means you need to know:

* How much leave is granted.
* How much is consumed.

**Step 2: Discover relevant tables**
Likely tables involved:

* `employee`
* `leave_type` (e.g., sick, casual, earned)
* `leave_allocation` (annual quota per type)
* `leave_request` (requests raised and approved)
* `holiday_master` (for excluding public holidays)

**Step 3: Understand relationships**

* `leave_allocation.employee_id → employee.id`
* `leave_request.employee_id → employee.id`
* `leave_request.leave_type_id → leave_type.id`

**Step 4: Explore sample queries**

```sql
SELECT 
  la.leave_type_id,
  lt.name AS leave_type,
  la.total_allocated,
  SUM(CASE WHEN lr.status = 'APPROVED' THEN lr.days_requested ELSE 0 END) AS used,
  (la.total_allocated - SUM(CASE WHEN lr.status = 'APPROVED' THEN lr.days_requested ELSE 0 END)) AS balance
FROM leave_allocation la
JOIN leave_type lt ON la.leave_type_id = lt.id
LEFT JOIN leave_request lr ON la.employee_id = lr.employee_id AND la.leave_type_id = lr.leave_type_id
WHERE la.employee_id = 101
GROUP BY la.leave_type_id, lt.name, la.total_allocated;
```

**Domain Insight from DB:**

* Leave logic is *per employee per type*.
* Business allows **leave requests** even if not yet approved (track by `status`).
* Balance is not stored — it’s calculated from allocation and approved leaves.

---

## 🧪 Use Case 2: “Find all customers with pending orders in E-Commerce system”

**Step 1: Understand the intent**

> Pending order = not shipped or not paid.

**Step 2: Find schema path**

* `customer`
* `order`
* `order_status` or `order.status`
* Possibly `payment` and `shipment`

**Step 3: Find business state flow**

* `order.status IN ('PENDING', 'CONFIRMED')`
* Payment may be partial
* Shipping not initiated yet

**Step 4: Sample domain-aware SQL**

```sql
SELECT c.id, c.name, o.id AS order_id, o.status
FROM customer c
JOIN order o ON c.id = o.customer_id
WHERE o.status IN ('PENDING', 'CONFIRMED');
```

**Deep Insights:**

* Status is a core business workflow field — every system has it.
* You can map workflow from status transitions.
* Real-time balance/status is better calculated than stored (to avoid stale data).

---

## 🧪 Use Case 3: “Show policy coverage and claim summary in Insurance system”

**Step 1: Key entities**

* `policy`, `policy_holder`, `coverage`, `claim`, `claim_status`

**Step 2: Data flow**

* 1 policy → many coverages
* 1 policy → many claims
* Each claim has a status (`submitted`, `approved`, `rejected`)

**Step 3: Practical query**

```sql
SELECT 
  p.policy_number,
  ph.name AS holder,
  COUNT(DISTINCT cov.id) AS coverage_count,
  COUNT(cl.id) AS total_claims,
  SUM(CASE WHEN cl.status = 'APPROVED' THEN cl.amount ELSE 0 END) AS approved_amount
FROM policy p
JOIN policy_holder ph ON p.holder_id = ph.id
LEFT JOIN coverage cov ON p.id = cov.policy_id
LEFT JOIN claim cl ON cl.policy_id = p.id
WHERE p.id = 2001
GROUP BY p.policy_number, ph.name;
```

**What you learn from schema:**

* Claims are traced via `policy_id`.
* Coverage is a sub-entity of policy — optional but critical.
* Every domain has financial calculation tables (e.g., claims, salaries, invoices).

---

## 🧪 Patterns and Techniques You Pick Up
```shell
| Technique                       | Purpose                                    | Example Use                     |
|---------------------------------|--------------------------------------------|---------------------------------|
| **Status-based filtering**      | Understand workflows and business states   | `status = 'APPROVED'`           |
| **Join on master tables**       | Map IDs to names/types                     | `leave_type`, `order_status`    |
| **Group by with SUM/COUNT**     | Aggregate business activity per entity     | Leave balance, claim summary    |
| **LEFT JOIN for optional data** | Include all main records, even if no child | Orders without shipment         |
| **Versioned/Soft-delete logic** | Trace active vs deleted records            | `is_deleted = 0`, `version = ?` |
| **Audit tables**                | Understand what changed and when           | `*_history`, `*_audit`          |
```
---

## 📌 Tips for Deep Diving via Schema

1. **Use sample records** to understand data shapes.
2. **Trace one real-time business query** end-to-end.
3. **Always find status columns** – they often reveal workflows.
4. **Look for surrogate keys (`id`) and reference keys (`code`)**.
5. **Compare current vs historical tables** to learn retention or business lifecycle.



