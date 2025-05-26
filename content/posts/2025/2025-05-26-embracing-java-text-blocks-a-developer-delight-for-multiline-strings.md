---
title: 'Embracing Java Text Blocks: A Developer Delight for Multiline Strings'
author: Abhishek
type: post
date: 2025-05-26T14:38:06+05:30
url: "/embracing-java-text-blocks-a-developer-delight-for-multiline-strings/"
toc: true
draft: false
categories: [ "java" ]
tags: [ "java-15-features" ]
---

A few months ago, I was helping a junior developer on our Spring Boot team debug a JSON string in a Java application.
The string was being constructed the old-fashioned way—line by line, with escaped quotes and newline characters peppered
everywhere. It was difficult to read, error-prone, and made version control diffs almost unreadable. After some
head-scratching and back-and-forth debugging, I remembered a feature introduced in Java 13 (and finalized in Java 15)—
**Text Blocks**.

That one change saved us time, made the code more readable, and sparked a mini knowledge-sharing session across our
team. Now, let me take you through the story of how Text Blocks became one of my favorite features in modern Java.

## Problem

Before Text Blocks, Java developers faced real pain when dealing with multiline strings, especially for:

* Embedding JSON/XML/HTML snippets
* Writing SQL queries
* Handling template files or configuration snippets

Example of a multiline JSON string the old way:

```java
String json = "{\n" +
        "  \"name\": \"John\",\n" +
        "  \"age\": 30,\n" +
        "  \"city\": \"New York\"\n" +
        "}";
```

Not only is it hard to read and maintain, but it also increases the chance of syntax errors, especially with escaping
characters.

## Solution: Java Text Blocks

Text Blocks provide a cleaner and more readable way to write multiline strings. Introduced as a preview feature in Java
13 and finalized in Java 15, a text block is a multiline string literal enclosed in triple double-quotes:

```java
String json = """
        {
          "name": "John",
          "age": 30,
          "city": "New York"
        }
        """;
```

## Multiple Examples with Detailed Explanation

### 1. JSON in REST Controllers

**Before:**

```java
String body = "{\"id\":123,\"name\":\"Book\"}";
```

**With Text Block:**

```java
String body = """
        {
          "id": 123,
          "name": "Book"
        }
        """;
```

**Use Case:** Helpful in writing mock JSON responses in unit/integration tests.

### 2. HTML/Thymeleaf Templates

```java
String html = """
        <html>
          <body>
            <h1>Welcome to Spring Boot!</h1>
          </body>
        </html>
        """;
```

**Use Case:** Useful when creating HTML templates for email or server-side rendering.

### 3. SQL Queries in Repositories

```java
String query = """
        SELECT id, name, email
        FROM users
        WHERE active = true
        ORDER BY created_at DESC
        """;
```

**Use Case:** Makes native SQL queries in Spring Data repositories more readable.

### 4. XML Configuration

```java
String xml = """
        <beans>
          <bean id="dataSource" class="org.apache.commons.dbcp2.BasicDataSource">
            <property name="driverClassName" value="com.mysql.cj.jdbc.Driver"/>
          </bean>
        </beans>
        """;
```

**Use Case:** For tools that consume XML (e.g., Spring Contexts or legacy systems).

### 5. cURL Script for Integration Testing

```java
String curl = """
        curl -X POST \
          http://localhost:8080/api/products \
          -H "Content-Type: application/json" \
          -d '{"name": "Mobile", "price": 499}'
        """;
```

**Use Case:** Storing and running external commands/scripts.

## Best Practices

1. **Keep Indentation Consistent:** Java will automatically determine the common leading whitespace and remove it.
2. **Use `String.stripIndent()` if needed:** For programmatically cleaning indentation.
3. **Combine with `String.format()` for dynamic values:**

```java
String name = "Alice";
String greeting = String.format("""
        Hello %s,
        Welcome to our system!
        """, name);
```

4. **Leverage for readability in test cases.**
5. **Use IDE support (like IntelliJ or Eclipse) for previewing text blocks formatting.**

## Anti Patterns

1. **Avoid Overuse:** Don’t use Text Blocks for single-line strings.
2. **Avoid Mixing Logic with Layout:** Keep text blocks for static or template content only, not dynamic logic.
3. **Don’t misuse for logging purposes:** Prefer structured logging rather than injecting multiline text blocks into
   logs.
4. **Avoid complex concatenation within a text block.** Instead, prepare values outside and insert them cleanly.

## Final Thoughts

Text Blocks may seem like a small feature, but they bring massive improvements in code readability, maintainability, and
developer happiness. Especially in Spring Boot applications, where JSON, SQL, and HTML snippets are everywhere, Text
Blocks shine brilliantly.

They're not just about writing strings—they're about writing **clean, expressive, and error-free code**.

## Summary

* Text Blocks were introduced to simplify multiline string handling.
* Enclosed in triple quotes `"""`, they preserve formatting and eliminate the need for escape characters.
* Great for embedding JSON, SQL, HTML, XML, and scripts.
* They clean up our test cases, configuration snippets, and inline queries.
* Adopt with best practices, and avoid common misuse.

## Good Quote

> "Simplicity is the soul of efficiency."   
> – Austin Freeman

That's it for today, will meet in next episode.

Happy coding 😀
