---
title: 'Java 9 Collection Factory Methods: A Cleaner Way to Create Collections'
author: Abhishek
type: post
date: 2025-05-16T11:37:07+05:30
url: "/java-9-collection-factory-methods-â-a-cleaner-way-to-create-collections/"
draft: false
categories: [ "java" ]
tags: [ "java-9-features" ]
---

A few years ago, I was working on a microservice that consumed reference data from an external API. We had to create a
static list of countries, currencies, and languages in our test cases repeatedly. The usual way—creating a `List`, then
calling `add()` multiple times—felt clunky. One day, during a code review, a junior developer asked: "Isn't there a
simpler way to initialize collections in one line?"

That question led me down the rabbit hole of Java 9's collection factory methods.

## Problem – Verbose and Error-Prone Collection Initialization

Before Java 9, creating a small unmodifiable list or map required boilerplate code:

```java
List<String> fruits = new ArrayList<>();
fruits.add("Apple");
fruits.add("Banana");
fruits.add("Orange");
fruits = Collections.unmodifiableList(fruits);
```

Or with `Arrays.asList()` (which returns a fixed-size list):

```java
List<String> fruits = Collections.unmodifiableList(Arrays.asList("Apple", "Banana", "Orange"));
```

This was either verbose or misleading. Maps were even worse:

```java
Map<String, Integer> ages = new HashMap<>();
ages.put("John",30);
ages.put("Alice",25);
ages = Collections.unmodifiableMap(ages);
```

## Solution – Java 9 Collection Factory Methods

Java 9 introduced new static methods on interfaces `List`, `Set`, and `Map`:

* `List.of(...)`
* `Set.of(...)`
* `Map.of(...)`
* `Map.ofEntries(...)`

These methods create **immutable** collections in a **concise** and **readable** way.

### Key Points:

* Null elements are **not allowed** (throws `NullPointerException`)
* Duplicates in `Set.of()` are **not allowed**
* These collections are **unmodifiable** (modification throws `UnsupportedOperationException`)

## Multiple Examples – Java 9 in Action

### 1. Creating a List

```java
List<String> colors = List.of("Red", "Green", "Blue");
System.out.println(colors);
```

* Output: `[Red, Green, Blue]`
* Any modification will throw exception:

```java
colors.add("Yellow"); // UnsupportedOperationException
```

### 2. Creating a Set

```java
Set<String> roles = Set.of("ADMIN", "USER", "VIEWER");
System.out.println(roles);
```

* Duplicate elements not allowed:

```java
Set.of("ADMIN","USER","ADMIN"); // IllegalArgumentException
```

### 3. Creating a Map with `Map.of()`

```java
Map<String, Integer> stock = Map.of(
        "Apple", 50,
        "Banana", 30,
        "Orange", 20
);
System.out.println(stock);
```

* Max 10 key-value pairs with `Map.of(...)`
* Beyond 10, use `Map.ofEntries(...)`

### 4. Creating a Map with `Map.ofEntries()`

```java
Map<String, String> countries = Map.ofEntries(
        Map.entry("IN", "India"),
        Map.entry("US", "United States"),
        Map.entry("FR", "France")
);
System.out.println(countries);
```

## Best Practices

* Use factory methods for creating small, constant collections
* Avoid modifying the returned collection
* Use them in DTOs, configuration, and test data
* Combine with `Stream.collect(Collectors.toUnmodifiableList())` for dynamic collections

```java
List<String> upper = Stream.of("a", "b", "c")
        .map(String::toUpperCase)
        .collect(Collectors.toUnmodifiableList());
```

## Anti-Patterns

* **Modifying returned collection**:

```java
List<String> list = List.of("A", "B");
list.add("C"); // UnsupportedOperationException
```

* **Using nulls**:

```java
List<String> list = List.of("A", null); // NullPointerException
```

* **Using for large, mutable datasets**:

    * These factory methods are not efficient for large or frequently modified collections.

## Final Thoughts

Java 9's collection factory methods simplify code by making it more declarative, concise, and error-proof. They are best
used for immutable collections, especially in constants, config, and tests. By avoiding manual collection
initialization, you reduce boilerplate and potential bugs.

If you still find yourself using `new ArrayList<>();` and `Collections.unmodifiableList(...)` for static data, it's time
to move on.

Use factory methods for small, constant collections to make code clearer and more robust.

## Summary
```java
| Feature                 | Description                                    |
| ----------------------- | ---------------------------------------------- |
| Methods                 | List.of`, `Set.of`, `Map.of`, `Map.ofEntries` |
| Immutable               | Yes                                            |
| Nulls                   | Not allowed                                    |
| Duplicates in Set       | Not allowed                                    |
| Max entries in `Map.of` | 10                                             |
| Modification            | Unsupported                                    |
```

## Good Quote

> "Simplicity is the ultimate sophistication."   
> – Leonardo da Vinci

That's it for today, will meet in next episode.  
Stay hydrated with java :grinning: