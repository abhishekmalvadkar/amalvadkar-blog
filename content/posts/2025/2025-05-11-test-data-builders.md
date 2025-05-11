---
title: 'Test Data Builders'
author: Abhishek
type: post
date: 2025-05-11T19:41:48+05:30
url: "/test-data-builders/"
toc: true
draft: false
categories: [ "Testing" ]
tags: [ "Testing", "Junit", "Best Practices", "AssertJ" ]
---

When writing unit tests in Java, you often need to create objects with many fields. Doing this repeatedly can make your
tests long, messy, and hard to understand. **Test Data Builders** help solve this by giving you a clean and flexible way
to create test objects with default values and easy overrides.
In this post, you’ll learn:

- The **problem** Test Data Builders solve
- A clear **solution** with practical Java examples
- **Best practices** for writing effective, clean builders

Let’s dive in.

## 1. Problem

In real-world unit testing, object creation often becomes a bottleneck, especially when:

- You need to create complex domain objects.
- Tests become cluttered with repetitive `new` constructors or factory method calls.
- Slight variations between test cases make object creation verbose and brittle.

```java
@Test
void should_create_user_with_valid_data() {
    User user = new User(
            "john.doe@example.com",
            "John",
            "Doe",
            LocalDate.of(1985, 5, 15),
            List.of("ADMIN", "USER")
    );

    assertThat(user.getEmail()).isEqualTo("john.doe@example.com");
}
```

## 2. Solution: Test Data Builders

```java
@Test
void should_create_user_with_valid_data() {
    User user = aUser().withEmail("john.doe@example.com").build();

    assertThat(user.getEmail()).isEqualTo("john.doe@example.com");
}
```

```java
public class UserTestBuilder {
    private String email = "default@example.com";
    private String firstName = "John";
    private String lastName = "Doe";
    private LocalDate dob = LocalDate.of(1990, 1, 1);
    private List<String> roles = List.of("USER");

    public static UserTestBuilder aUser() {
        return new UserTestBuilder();
    }

    public UserTestBuilder withEmail(String email) {
        this.email = email;
        return this;
    }

    public UserTestBuilder withRoles(List<String> roles) {
        this.roles = roles;
        return this;
    }

    public User build() {
        return new User(email, firstName, lastName, dob, roles);
    }
}
```

## 3. Best Practices

### Use static factory methods (`aUser()`, `anOrder()`)

Using descriptive static methods like `aUser()` or `anOrder()` instead of `new UserTestBuilder()` improves test readability. It reads more like English and conveys intent clearly:
```java
User user = aUser().withEmail("john@example.com").build();
```
This makes your test setup expressive and easier to understand at a glance.

### Keep sensible defaults

Your builder should create a **valid** object even when no custom fields are set. These defaults save time and keep tests focused only on the fields being verified. For example:
```java
User defaultUser = aUser().build(); // Still a valid User object
```
This makes test setup effortless for most scenarios.

### Use fluent API for overrides

Design your builder with chainable `withX()` methods to allow easy overriding of specific fields:
```java
User user = aUser()
    .withEmail("custom@example.com")
    .withRoles(List.of("ADMIN"))
    .build();
```
This keeps the object creation concise and readable, without needing many builder method variations.

### Keep builders in `test` sources

Test builders are meant to support **test code**, not production code. So keep them under `src/test/java`, not `src/main/java`. This keeps your production codebase clean and ensures builders are only used where appropriate.

### Avoid test smells

Avoid duplicating similar builder logic across test classes. Instead:
- **Reuse** common builders
- **Compose** them if needed (e.g., `aUser().withAddress(aDefaultAddress().build())`)
- Keep builders **DRY** and focused

This leads to better maintainability and avoids bloated or duplicated builder classes.

### Use AssertJ for clean assertions

For cleaner and more readable assertions, use **AssertJ**:
```java
assertThat(user)
    .hasFieldOrPropertyWithValue("email", "john.doe@example.com")
    .hasFieldOrPropertyWithValue("roles", List.of("ADMIN", "USER"));
```

## Conclusion

Test Data Builders + AssertJ + JUnit = **Clean, Intent-Focused, Maintainable Tests**

They help you:

- Avoid verbose object setup
- Write tests that express what matters
- Easily adapt to evolving domain models

Start small, use builders only where they add clarity, and you’ll quickly see improvements in the quality and
maintainability of your tests.

That's it for today, will meet in next episode.

Happy testing :grinning:
