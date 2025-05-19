---
title: 'Spring Boot Jpa Schema Validation With Custom Failure Analyzer'
author: Abhishek
type: post
date: 2025-05-19T12:38:07+05:30
url: "/spring-boot-jpa-schema-validation-with-custom-failure-analyzer/"
toc: true
draft: false
categories: [ "JPA", "spring boot" ]
tags: [ "jpa-best-practices" , "spring-boot-best-practices" ]
---

It was a Friday evening and the QA team was trying to push the latest build to staging. Everything had worked perfectly
in development, and CI had shown green ticks. What made things worse was this: **by default, Hibernate does not validate
the schema at startup**. This means the application **started without error**, giving the false impression that
everything was fine. But when the spefific API request hit the database which is related to missing column or table, 
a runtime exception occurred—**column not found**.The error came too late, and debugging it took hours.

This incident reminded us of one thing: **developers need better feedback when the schema is incorrect at startup**.

## Problem

When using Spring Boot with Spring Data JPA (Hibernate), the application can fail silently or cryptically during startup
if:

* A table is missing.
* A column is missing or has a wrong type.
* Schema evolution wasn't correctly applied.

In production or staging, where DDL auto-update is disabled (`spring.jpa.hibernate.ddl-auto=none`), these issues are
common. The default startup failure logs are vague, unfriendly, and often missed in large logs.

To make it worse, without explicitly enabling validation, Hibernate does **not check the schema at all**. This results
in:

* Application starting normally
* Failure happening only during actual query execution at runtime
* Delayed error feedback and difficult debugging

## Solution

Spring Boot allows us to:

1. Enable schema validation at startup using Hibernate.
2. Write a **custom `FailureAnalyzer`** that captures these schema errors and displays a **clear, developer-friendly
   message**.

This blog will walk through how to do both, with examples, best practices, and common anti-patterns.

## Step-by-Step Solution with Examples

### Enable Schema Validation

In `application.yml` or `application.properties`, set:

```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: validate
```

This ensures that on startup, Hibernate will compare the entity model with the existing database schema and throw an
exception if they mismatch.

### Common Validation Errors

Let’s walk through some examples:

### Example 1: Missing Table

```java

@Entity
public class Product {
    @Id
    private Long id;
    private String name;
}
```

If the `product` table is missing from the DB and `ddl-auto=validate`, startup fails with:

```shell
Schema-validation: missing table [product]
```

### Example 2: Missing Column

```java

@Entity
public class User {
    @Id
    private Long id;
    private String email;
}
```

If the `email` column is missing in the `user` table:

```shell
Schema-validation: missing column [email] in table [user]
```

### Create Custom FailureAnalyzer

Let’s create a custom `FailureAnalyzer` to intercept schema validation exceptions and print a clean message.

### Step 1: Implement `FailureAnalyzer`

```java
public class SchemaValidationFailureAnalyzer extends AbstractFailureAnalyzer<SchemaManagementException> {
    @Override
    protected FailureAnalysis analyze(Throwable rootFailure, SchemaManagementException cause) {
        String description = """
                Database schema validation failed.
                Reason: %s""".formatted(cause.getMessage());
        String action = """
                Suggested Actions:
                - Ensure the schema is updated to match your entities.
                - Run migrations if using Flyway or Liquibase.
                - Review the column/table names for typos.""";

        return new FailureAnalysis(description, action, cause);
    }
}
```

### Step 2: Register the Analyzer

Create a file:

```text
META-INF/spring.factories
```

Add:

```properties
org.springframework.boot.diagnostics.FailureAnalyzer=your.package.SchemaValidationFailureAnalyzer
```

### Step 3: Output on Startup Failure

When validation fails, instead of raw stack trace, you'll see:

```shell
***************************
APPLICATION FAILED TO START
***************************

Description:

Database schema validation failed.

Reason: Schema-validation: missing column [email] in table [user]

Suggested Actions:
- Ensure the schema is updated to match your entities.
- Run migrations if using Flyway or Liquibase.
- Review the column/table names for typos.
```

## Best Practices

* **Always use `ddl-auto=validate` or `ddl-auto=none` in staging/production**.
* **Automate schema evolution** using Flyway or Liquibase.
* **Use CI/CD to validate schema** during build pipelines.
* **Write a FailureAnalyzer** to help teams debug faster.
* **Keep entity and schema versions in sync**.

## Anti Patterns

* Using `ddl-auto=update` in production.
* Relying on Hibernate to create or alter schema in any environment beyond dev.
* Ignoring startup exceptions and letting logs grow silently.
* Not validating schema in CI before deployment.

## Final Thoughts

Schema mismatches can break your app on startup and ruin developer experience. By combining schema validation and a
custom failure analyzer, you can catch these issues early and help your team fix them fast.

Remember, **developer happiness is critical**—clear messages at startup prevent hours of frustration.

## Summary

* Use `ddl-auto=validate` to enforce schema match.
* Create a `FailureAnalyzer` to display friendly messages.
* Automate schema checks in CI.
* Avoid anti-patterns like auto-updates in staging/production.

> "A great developer experience starts with great error messages."
> — Unknown

That's it for today, will meet in next episode.  
Happy best practices :grinning:



