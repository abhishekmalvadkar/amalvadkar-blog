---
title: 'How Spring Data Jpa Creates Proxy Implementation of Repository Interface'
author: Abhishek
type: post
date: 2025-06-16T11:46:31+05:30
url: "/how-spring-data-jpa-creates-proxy-implementation-of-repository-interface/"
toc: true
draft: false
categories: [ "SPRING DATA JPA" ]
tags:
- spring-magic
---

A couple of years back, I joined a fast-moving fintech startup as a senior Java developer. During my first week, I was
going through an existing Spring Boot project to fix a seemingly small issue in a loan processing flow. As I navigated
through the code, I noticed a peculiar pattern: there were interfaces like `LoanRepository` and `CustomerRepository`,
but **no concrete implementations** in sight.

I thought maybe I missed a naming convention, or perhaps the actual logic was in some abstract superclass. I used
IntelliJ’s “Go to Implementation” shortcut. Nothing.

And yet, the application was running just fine, persisting data into MySQL, querying customer details, updating
loans—all without any visible implementation of these interfaces.

Then came the big realization: **Spring Data JPA was doing some serious magic** behind the scenes.

That led me down the rabbit hole to understand *how exactly* Spring Data JPA creates the runtime implementations of
repository interfaces. And what I discovered completely changed the way I looked at Spring and proxies.

Let me take you through what I learned.

---

## The Magic: Spring Data JPA and Proxy-Based Repositories

Spring Data JPA allows you to define interfaces like this:

```java
public interface CustomerRepository extends JpaRepository<Customer, Long> {
    List<Customer> findByLastName(String lastName);
}
```

And without writing a single line of implementation code, it gives you a fully working repository.

But how?

The answer lies in **proxy generation**, **Spring’s infrastructure beans**, and a bit of **bytecode trickery**.

## Step-by-Step Explanation of What Happens

### 1. Spring Boot Auto-Configuration Kicks In

When you add `spring-boot-starter-data-jpa` to your `pom.xml`, Spring Boot automatically enables a bunch of
auto-configurations:

* `@EnableJpaRepositories` is activated (via `JpaRepositoriesAutoConfiguration`)
* This annotation scans your project for interfaces that extend `JpaRepository`, `CrudRepository`, etc.

### 2. Spring Registers Repository Interfaces as Beans

The `@EnableJpaRepositories` triggers the `JpaRepositoriesRegistrar`, which is responsible for registering JPA
repository interfaces as Spring beans.

At this point, Spring:

* Scans your classpath for interfaces extending `JpaRepository`
* Creates a bean definition for each repository interface

But remember—**there’s no actual class implementing these interfaces yet**.

### 3. Spring Creates a Proxy

When Spring creates the application context, it doesn’t try to instantiate `CustomerRepository` directly. Instead, it
creates a **proxy** object that implements the same interface.

There are two main techniques Spring can use to create proxies:

* **JDK Dynamic Proxy**: If you inject the interface (`CustomerRepository`), Spring uses `java.lang.reflect.Proxy` to
  create a runtime class that implements it.
* **CGLIB Proxy**: If a concrete class is injected or if Spring needs to subclass something, it uses CGLIB to create a
  bytecode-based subclass.

In the case of Spring Data JPA, most proxies are created using **JDK dynamic proxies**, because the repository is
usually injected as an interface.

### 4. The Proxy Delegates to a Real Implementation Behind the Scenes

The proxy created doesn’t hold any real logic itself. Instead, it delegates all method calls to an instance of
`SimpleJpaRepository`, the default implementation provided by Spring Data JPA.

In fact, if you look at the source code of Spring Data, you’ll find:

```java
public class SimpleJpaRepository<T, ID> implements JpaRepository<T, ID> {
    // actual implementation here
}
```

So, when you write:

```java
customerRepository.findByLastName("Smith");
```

What really happens is:

* The proxy intercepts the method call
* It checks if the method is one of the standard ones from `JpaRepository`
* It delegates to `SimpleJpaRepository`

For custom methods like `findByLastName`, Spring Data uses a method parser to convert that into a JPQL query:

```sql
SELECT c FROM Customer c WHERE c.lastName = :lastName
```

This query is compiled, cached, and executed using the EntityManager under the hood.

### 5. Spring Uses Repositories Through `RepositoryFactoryBeanSupport`

The glue that connects all of this is `RepositoryFactoryBeanSupport`. It’s responsible for:

* Instantiating the proxy
* Injecting the EntityManager
* Mapping the interface to its underlying implementation (`SimpleJpaRepository` by default)

You can even override the factory to provide your own custom base implementation for all repositories.

## What If You Add Custom Logic?

You can do something like:

```java
public interface LoanRepositoryCustom {
    void customBatchInsert(List<Loan> loans);
}

public class LoanRepositoryImpl implements LoanRepositoryCustom {
    // your implementation
}

public interface LoanRepository extends JpaRepository<Loan, Long>, LoanRepositoryCustom {
}
```

Spring will automatically wire `LoanRepositoryImpl` as the implementation of the `LoanRepositoryCustom` part of your
interface and still use the proxy to bridge everything together.

## Why This Matters as a Developer

Understanding this proxy mechanism is important because:

* You now know where and how to debug things
* You understand why method names matter (`findBy`, `existsBy`, etc.)
* You can build your own `BaseRepository` and plug it into the factory
* You can avoid common pitfalls like calling repository methods in constructors (too early in proxy lifecycle)

Also, this knowledge helps you debug class cast exceptions or mysterious bean issues that stem from proxy mismatches.

## Final Thoughts

That day I wondered, “Where is the implementation?” and now I know that the implementation is everywhere—just not
visible. It's in the proxy, in the factory bean, in `SimpleJpaRepository`, and in Spring’s incredible infrastructure.

What seemed like magic turned out to be a **brilliantly engineered proxy-based factory pattern** in action.

So next time you define a `JpaRepository`, know that you're getting a proxy that speaks to your database with
elegance—and a lot of engineering muscle under the hood.

Happy coding! 🎯
