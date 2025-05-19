---
title: 'Primitive vs Object Variables as Jpa Entity Id Property'
author: Abhishek
type: post
date: 2025-05-19T12:13:24+05:30
url: "/primitive-vs-object-variables-as-jpa-entity-id-property/"
toc: true
draft: false
categories: [ "JPA" ]
tags: [ "jpa-best-practices" ]
---

It was during a routine code review when a junior developer asked, *"Should I use `long` or `Long` for my JPA entity ID?
Does it really matter?"* It was a seemingly innocent question, one I had encountered multiple times across various
projects. At first glance, it feels trivial, but underneath lies a set of implications that affect nullability,
persistence state, consistency, and readability.

This prompted a detailed discussion with the team, where we dissected the implications of using primitive vs wrapper
types as identifier fields in JPA entities. What began as a small debate over data types ended with new insights, a
deeper understanding of Hibernate behavior, and several revisions to our team’s coding standards.

## Problem

In JPA entities, the ID property represents the primary key — the most fundamental part of the object-relational
mapping. The confusion arises when choosing between:

* `long` (primitive)
* `Long` (wrapper/object)

Both are used frequently, but the choice has subtle yet significant consequences. Developers often default to primitives
for performance, but in the context of JPA, this can lead to issues, particularly around object state tracking,
nullability, and equality checks.

## Key Challenges

1. **Nullability:** Primitive types like `long` cannot be `null`. However, new (transient) entities do not have IDs
   until they are persisted.
2. **Hibernate Identity Generation:** Hibernate often relies on `null` values to determine if the entity is new.
3. **Default Values:** Java assigns a default value (`0`) to uninitialized primitives, which can mislead Hibernate.
4. **Equality Checks:** Improper handling of `equals()` and `hashCode()` when the ID is `0` or unset can break
   collections like `Set` or `Map`.

## Solution

Use the wrapper type (`Long`, `Integer`, etc.) instead of the primitive for the ID field in JPA entities. This allows
the ID to remain `null` until assigned by the persistence provider, enabling correct lifecycle tracking and avoiding
confusion over default primitive values.

```java

@Entity
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    // getters and setters
}
```

This simple change ensures that the entity is correctly recognized as new when `id == null` and that the ORM does not
confuse a default `0` value with an already persisted entity.

## Multiple Examples with Detailed Explanation

### Example: Using `long` as ID

```java

@Entity
public class Customer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    private String name;

    // equals() and hashCode() use id
}
```

### Problem Here:

* Before persisting, `id` is `0`, not `null`.
* Hibernate may not consider the entity as new.
* Any logic using `id == 0` as a check for non-persistence is fragile.
* Sets and Maps using this entity as a key may behave incorrectly if `equals()` and `hashCode()` rely on `id`.

### Example: Using `Long` as ID

```java

@Entity
public class Customer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    // equals() and hashCode() safely handle null ids
}
```

#### Benefits:

* `null` indicates a transient state.
* Clear differentiation between new and existing entities.
* Compatible with Hibernate’s expectations.

### Example: Equality Issue

```java

@Override
public boolean equals(Object o) {
    if (this == o) return true;
    if (!(o instanceof Customer)) return false;
    Customer that = (Customer) o;
    return Objects.equals(id, that.id);
}

@Override
public int hashCode() {
    return Objects.hash(id);
}
```

Using `Long` ensures that `null` IDs don’t break equality, especially before persistence. If `long` is used, then two
different instances might have `id == 0`, causing equality issues.

## Best Practices

1. **Always use Wrapper Types (`Long`, `Integer`) for ID fields in JPA entities.**
2. **Avoid using `equals()` or `hashCode()` that depend on ID for transient entities.**
    * Use business keys or UUIDs if equality is critical before persistence.
3. **Let JPA handle ID assignment — don’t manually set IDs unless necessary.**
4. **Initialize relationships lazily and avoid cascading from unsaved entities with primitive IDs.**
5. **Use `@EqualsAndHashCode(onlyExplicitlyIncluded = true)` with Lombok or override manually with care.**

## Anti-Patterns

* Using `long` or `int` for `@Id` fields in JPA entities.
* Implementing `equals()` and `hashCode()` solely on `id` when it's primitive.
* Manually assigning IDs before persistence.
* Relying on `id == 0` to check for new entity state.

## Final Thoughts

Primitive types have their place in Java, particularly for performance-sensitive calculations and tight loops. However,
in the world of object-relational mapping, semantics matter more than micro-optimizations.

The choice of `Long` over `long` is not about performance — it’s about correctness, clarity, and alignment with the
persistence provider’s expectations. A simple decision can have ripple effects on the behavior of your application.
Understand the implications, and you’ll build more robust and predictable systems.

## Summary

**Nullability**  
  `Primitive (long)`: ❌ Cannot be null  
  `Object (Long)`: ✅ Can be null

**Default value**  
`Primitive (long)`: `0`  
`Object (Long)`: `null`  

**Hibernate behavior**  
`Primitive (long)`: May assume persisted  
`Object (Long)`: Correctly identifies new entity  

**Equality logic**  
`Primitive (long)`: Fragile  
`Object (Long)`: Reliable  

**Best practice**  
`Primitive (long)`: ❌ Avoid  
`Object (Long)`: ✅ Prefer  

* Always prefer object wrappers (`Long`, `Integer`) for JPA IDs.
* Don’t rely on default primitive values for entity lifecycle decisions.
* Align with JPA and Hibernate expectations for smoother persistence handling.

## Good Quote

> “Small decisions, like choosing between `long` and `Long`, define the foundation of great software. The devil truly is
> in the details.” – Anonymous Architect

That's it for today, will meet in next episode.  
Happy jpa :grinning:
