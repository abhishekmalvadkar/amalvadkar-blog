---
title: 'Fetch Everything Together From Backend to Reduce Multiple Network Calls'
author: Abhishek
type: post
date: 2025-05-28T11:54:58+05:30
url: "/fetch-everything-together-from-backend-to-reduce-multiple-network-calls/"
draft: true
toc: true
categories: [ "frontend system design" ]
tags: [ 'performance-optimization' ]
---

It was a busy Monday morning. Emma, a senior frontend engineer, had just deployed a new version of the product
dashboard. But shortly after deployment, performance complaints started flooding in. "The page is too slow!", "Why does
it take forever to load?", users complained.

Emma opened Chrome DevTools and saw it—over 30+ API calls made to render one single dashboard page. Each chart, widget,
and data point fetched its own data with separate requests. Most APIs were returning relatively small payloads, yet the
latency added up. Emma sighed, realizing this could have been prevented with a more thoughtful backend design.

The problem wasn’t the frontend or even the backend APIs individually—it was the orchestration of data retrieval. It was
time to **fetch everything together** in one optimized backend call.

## Problem

In modern web and mobile applications, it’s common for the UI to be modular and component-based. While this is great for
development, it often leads to:

* **Multiple redundant network calls**
* **Increased latency due to multiple round-trips**
* **Complex orchestration logic in the frontend**
* **Inconsistent or partial data during render time**

When each UI component independently fetches its data, the application can become chatty—sending many small, fragmented
requests instead of a cohesive data fetch. This results in performance bottlenecks, poor user experience, and increased
infrastructure load.

## Solution: Fetch Everything Together (FET)

**Fetch Everything Together (FET)** is a backend optimization pattern where you aggregate and send all the required data
for a page or view in a single API call.

Instead of making 10 small API requests from the frontend, you make **one comprehensive request** that delivers all the
required data together, even if they belong to different modules or contexts.

This often requires a backend orchestration layer that:

* Understands the frontend's data requirements
* Delegates and composes data from various services or repositories
* Returns a structured response tailored to the frontend

## Multiple Examples in Detail

### 1. Dashboard Page with Charts, Stats, and User Info

**Before FET:**

* `/api/user/profile`
* `/api/user/notifications`
* `/api/dashboard/stats`
* `/api/dashboard/revenue`
* `/api/dashboard/conversion`

**After FET:**

* `/api/dashboard/overview`

  ```json
  {
    "profile": { "name": "Emma", "role": "admin" },
    "notifications": [...],
    "stats": {...},
    "revenue": {...},
    "conversion": {...}
  }
  ```

**Explanation:**
One API call serves all required data. Internally, the backend orchestrates the calls and composes the response.

---

### 2. Mobile App Home Screen

**Before FET:**

* `/api/user/profile`
* `/api/feed/posts`
* `/api/feed/stories`
* `/api/recommendations`

**After FET:**

* `/api/home/data`

**Explanation:**
For mobile, minimizing network usage and battery is crucial. A single call improves cold start performance and avoids
race conditions.

---

### 3. E-commerce Product Detail Page

**Before FET:**

* `/api/products/{id}`
* `/api/products/{id}/reviews`
* `/api/products/{id}/related`
* `/api/inventory/{id}`

**After FET:**

* `/api/products/{id}/full`

  ```json
  {
    "product": {...},
    "reviews": [...],
    "relatedProducts": [...],
    "inventory": {...}
  }
  ```

**Explanation:**
Provides all product detail context with just one API, reducing latency and complexity.

---

## Best Practices

1. **Design DTOs for Views:** Tailor your response DTOs to match the frontend view models.
2. **Use Aggregator Services:** Create an orchestrator or facade layer in the backend to collect data from multiple
   microservices or repositories.
3. **Support Partial Fetching:** Allow optional params to control which sections to fetch (e.g.,
   `?include=reviews,inventory`).
4. **Document Contracts Clearly:** Document the structure and optional sections for frontend developers.
5. **Paginate Internally:** Avoid bloated payloads by using pagination or lazy loading where needed.
6. **Leverage Caching:** Use caching at different layers (memory, Redis, HTTP) for static or slow-changing parts of the
   response.

## Anti-Patterns

1. **One Huge Global API Call:** Fetching everything for the entire app in one call—even data not required.
2. **Monolithic Controller Logic:** Putting all aggregation logic in the controller class.
3. **Ignoring Network Failures:** Not handling partial failures or fallback strategies in orchestrator logic.
4. **Tightly Coupled DTOs:** Making the frontend dependent on backend entity structures instead of dedicated view
   models.
5. **Overloading with Rarely Used Data:** Including unnecessary data fields in the response payload.

## Recommended Book

📘 **Designing Web APIs** by Brenda Jin, Saurabh Sahni, Amir Shevat — it teaches practical techniques for building
consumable, composable APIs that align well with patterns like Fetch Everything Together.

## Final Thoughts

Fetching everything together is a powerful technique that improves performance, user experience, and frontend
simplicity. It aligns with the principle of **smart backend, simple frontend**. While not every use case requires this
strategy, it often leads to a significant improvement in application responsiveness and scalability.

In performance-critical applications, especially dashboards, home screens, or mobile apps, this strategy is
indispensable.

## Summary

* Modular frontend often leads to too many API calls.
* Fetch Everything Together (FET) aggregates data into a single backend API call.
* It's ideal for dashboards, mobile apps, and performance-critical UIs.
* Use orchestrators, DTOs, partial fetching, and proper documentation.
* Avoid bloated or monolithic fetch-all APIs.

## Good Quote

> "Smart systems don't just work fast—they know what not to ask for." – Unknown

That's it for today, will meet in next episode.

**Happy coding 😃**
