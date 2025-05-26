---
title: 'Jpa Proxy Pitfall: When Eager Becomes Lazy'
author: Abhishek
type: post
date: 2025-05-26T18:23:48+05:30
url: "/jpa-proxy-pitfall-when-eager-becomes-lazy/"
toc: true
draft: false
categories: [ "jpa" ]
tags: [ "jpa-troubleshooting" ]
---

While working on a critical Spring Boot microservice using JPA and Hibernate, I ran into a puzzling issue. One of my
entity relationships was marked as `EAGER`, yet when I fetched the entity, the associated entity came back as a
**proxy**. At first, I didn’t notice it because everything seemed fine—until I modified a property inside that
associated
entity and merged the parent entity. The expected update didn’t happen.

At this point, I scratched my head. I was sure that JPA’s `EAGER` fetch strategy should have loaded the associated
entity completely. So why wasn’t it working as expected? After a bit of debugging and reading Hibernate documentation, I
found the culprit—and more importantly, the fix.

## Problem

Let’s break down the problem:

* I had an entity, say `Order`, with an associated `Customer` entity.

* The relationship in `Order` was marked as:

  ```java
  @ManyToOne(fetch = FetchType.EAGER)
  private Customer customer;
  ```

* However, when I retrieved an `Order` using `EntityManager.find()` or through a repository call, the `customer` was
  still a **proxy object** (i.e., not fully initialized).

* I changed a property inside this proxy:

  ```java
  order.getCustomer().setName("New Name");
  entityManager.merge(order);
  ```

* But no update went to the database!

This happened because the proxy was never initialized, and the changes didn’t get tracked.

## Why Does This Happen?

Despite `EAGER` fetching, some JPA providers (especially Hibernate) optimize data retrieval by still using proxies when
it thinks it’s safe. This optimization might be fine for read-only operations, but in update scenarios, it becomes
dangerous if developers assume the associated entity is fully loaded.

## Solution: Entity Graphs to the Rescue

To ensure that the associated entity was always fetched fully, I used **JPA Entity Graphs**.

### What’s an Entity Graph?

An Entity Graph allows you to programmatically or declaratively define which associations should be fetched. It
overrides the default `FetchType` (including `EAGER` or `LAZY`) when fetching entities.

### How I Fixed It

I defined an entity graph like this:

```java

@EntityGraph(attributePaths = {"customer"})
Order findById(Long id);
```

Or using the EntityManager:

```java
EntityGraph<Order> graph = entityManager.createEntityGraph(Order.class);
graph.addAttributeNodes("customer");

Map<String, Object> hints = new HashMap<>();
hints.put("javax.persistence.fetchgraph",graph);

Order order = entityManager.find(Order.class, id, hints);
```

This ensured that the `customer` entity was fully fetched (not a proxy), and all changes were tracked as expected.

## Multiple Examples

### 1. OneToMany with Entity Graph

Suppose `Department` has a `List<Employee>`:

```java

@Entity
public class Department {
    @OneToMany(mappedBy = "department", fetch = FetchType.LAZY)
    private List<Employee> employees;
}
```

To fetch employees along with department:

```java

@EntityGraph(attributePaths = {"employees"})
Department findByName(String name);
```

This prevents the N+1 problem and ensures full initialization.

### 2. Nested Associations

To fetch `Order` with `Customer` and `Address` (nested inside customer):

```java

@EntityGraph(attributePaths = {"customer", "customer.address"})
Order findById(Long id);
```

Or with EntityManager:

```java
EntityGraph<Order> graph = entityManager.createEntityGraph(Order.class);
Subgraph<Customer> customerGraph = graph.addSubgraph("customer");
customerGraph.addAttributeNodes("address");

Map<String, Object> hints = new HashMap<>();
hints.put("javax.persistence.fetchgraph",graph);

Order order = entityManager.find(Order.class, id, hints);
```

### 3. Dynamic Entity Graph with CriteriaQuery

```java
CriteriaBuilder cb = entityManager.getCriteriaBuilder();
CriteriaQuery<Order> cq = cb.createQuery(Order.class);
Root<Order> root = cq.from(Order.class);
cq.select(root).where(cb.equal(root.get("id"), 123L));

EntityGraph<Order> graph = entityManager.createEntityGraph(Order.class);
graph.addAttributeNodes("customer");

List<Order> orders = entityManager.createQuery(cq)
        .setHint("javax.persistence.fetchgraph", graph)
        .getResultList();
```

## Best Practices

* **Prefer LAZY fetching** in entity definitions to avoid unnecessary data loading.
* Use **Entity Graphs** for controlled, precise eager loading based on use case.
* Always **check for proxies** before modifying associated entities, especially during merge operations.
* Use `instanceof HibernateProxy` and `Hibernate.unproxy()` for defensive coding when needed.
* Define **named entity graphs** for reuse:

  ```java
  @NamedEntityGraph(name = "Order.customer", attributeNodes = @NamedAttributeNode("customer"))
  ```

## Anti-Patterns

* Blindly relying on `FetchType.EAGER` for all associations—this leads to performance and behavior issues.
* Modifying proxy objects assuming they are fully loaded.
* Ignoring `EntityGraph` when working with complex object graphs.
* Overusing entity graphs without profiling or understanding the performance impact.

## Final Thoughts

JPA and Hibernate offer a lot of flexibility, but sometimes this flexibility comes with surprises. Just because
something is marked as `EAGER` doesn’t mean it will behave that way in all cases. Understanding how and when to use
`EntityGraph` can save you from painful debugging sessions and unexpected production issues.

Entity Graphs are not just about performance—they're about correctness. They give us a declarative and reusable way to
control fetch behavior, especially in complex domain models.

## Summary

* JPA may return proxies even for `EAGER` associations.
* Changing proxy fields may not be persisted if the proxy is not initialized.
* Entity Graphs solve this problem by fully fetching the associated entities.
* Use entity graphs in repositories, EntityManager, or criteria queries.
* Prefer LAZY loading by default, override with graphs as needed.

> "In software development, assumptions are the termites of correctness."

That's it for today, will meet in next episode.

Happy coding 😃
