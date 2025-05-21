---
title: 'Private Methods in Interfaces Java 9 Deep Dive'
author: Abhishek
type: post
date: 2025-05-21T13:36:31+05:30
url: "/private-methods-in-interfaces-java-9-deep-di/"
toc: true
draft: false
categories: [ "java" ]
tags: [ "java-9-features" ]
---

During a code review session at our office, a junior developer named Ravi was working on refactoring an interface that
had several `default` and `static` methods. He complained, "I wish I could reuse this chunk of code in both default
methods, but I can't create a private method in an interface!" The room went quiet for a second — until our tech lead
smiled and said, "Actually, since Java 9, you *can*."

This small feature — the ability to have `private` methods inside interfaces — isn’t often highlighted in Java 9's
release notes, which are dominated by modules and JShell. But it's a powerful addition that significantly improves code
reuse and maintainability inside interfaces.

## Problem

Before Java 9, interfaces could contain:

* Abstract methods (since Java 1.0)
* `default` methods (since Java 8)
* `static` methods (since Java 8)

While `default` and `static` methods allowed implementation logic, they couldn’t share private logic within the
interface.

For instance:

```java
public interface Logger {
    default void logInfo(String msg) {
        System.out.println("INFO: " + msg);
        // duplicate logic
    }

    default void logError(String msg) {
        System.err.println("ERROR: " + msg);
        // duplicate logic
    }
}
```

Here, any common logging logic had to be repeated or moved to a utility class — breaking encapsulation and cluttering
the code.

## Solution

Java 9 introduced **private methods in interfaces**, which allow code sharing among `default` and `static` methods in a
cleaner way. There are two types:

* **private instance methods**: reusable by `default` methods.
* **private static methods**: reusable by `static` methods.

This change makes interfaces more powerful without breaking the interface abstraction.

## Multiple Examples in Detailed Fashion with Explanation

### Example 1: Reusing Logic in Default Methods

```java
public interface Logger {

    default void logInfo(String msg) {
        log("INFO", msg);
    }

    default void logError(String msg) {
        log("ERROR", msg);
    }

    private void log(String level, String msg) {
        System.out.println(level + ": " + msg);
    }
}
```

**Explanation**:

* The private method `log()` is shared between both default methods.
* Reduces duplication and improves clarity.

### Example 2: Reusing Logic in Static Methods

```java
public interface MathUtils {

    static int square(int number) {
        return multiply(number, number);
    }

    static int cube(int number) {
        return multiply(number, multiply(number, number));
    }

    private static int multiply(int a, int b) {
        return a * b;
    }
}
```

**Explanation**:

* A private static method `multiply()` is reused by static utility methods.
* Keeps implementation detail hidden from consumers of the interface.

### Example 3: Combining Default and Static With Respective Private Methods

```java
public interface DateUtils {

    default String getTodayFormatted() {
        return format(LocalDate.now());
    }

    static String getFormatted(LocalDate date) {
        return staticFormat(date);
    }

    private String format(LocalDate date) {
        return date.format(DateTimeFormatter.ISO_DATE);
    }

    private static String staticFormat(LocalDate date) {
        return date.format(DateTimeFormatter.ISO_DATE);
    }
}
```

**Explanation**:

* `format()` is a private instance method, used by default method.
* `staticFormat()` is a private static method, used by static method.
* Encapsulation maintained beautifully within the interface.

## Best Practices

* Use private methods to eliminate duplication inside interfaces.
* Use meaningful names to reflect purpose, just like in class methods.
* Keep private methods focused and small.
* Don’t expose internal logic via public or default methods unnecessarily.

## Anti Patterns

* **Don’t overuse private methods** just because you can. If your interface has complex logic, consider moving it to an
  abstract class.
* **Avoid stateful logic** inside interfaces — interfaces should remain stateless.
* **Do not use private methods to hide poor design decisions** — refactor appropriately.
* **Avoid mixing concerns** — interfaces should define contracts, not host business logic.

## Final Thoughts

Private methods in interfaces might seem like a small enhancement, but they represent Java's gradual evolution toward
better modularity and code reuse. By enabling this feature, Java 9 empowered developers to write cleaner, DRY-compliant
interface implementations.

It’s not about writing more code in interfaces — it’s about writing better, maintainable code where appropriate.

## Summary

* Java 9 introduced **private methods in interfaces**.
* These methods can be `private` or `private static`.
* They help avoid duplication in `default` and `static` methods.
* They improve encapsulation and maintainability.
* Avoid abusing the feature — use them wisely.

## Good Quote

> "Good code is its own best documentation. As you're about to add a comment, ask yourself, 'How can I improve the code
> so that this comment isn't needed?'"   
> – Steve McConnell

That's it for today, will meet in next episode.  
Happy coding :grinning:
