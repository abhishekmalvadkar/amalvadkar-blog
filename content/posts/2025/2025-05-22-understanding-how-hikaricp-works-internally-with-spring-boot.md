---
title: 'Understanding How HikariCP Works Internally With Spring Boot'
author: Abhishek
type: post
date: 2025-05-22T12:39:01+05:30
url: "/understanding-how-hikaricp-works-internally-with-spring-boot/"
toc: true
draft: false
categories: [ "spring boot" ]
tags: [ "spring-transaction" , "connection-pool" ]
---

It was a busy Monday morning, and our microservices-based system was under heavy load. Suddenly, we started receiving
complaints from the support team: "The system is down!" Upon investigation, we found that some services were throwing
exceptions like `SQLTransientConnectionException: HikariPool-1 - Connection is not available`. Our database wasn’t down,
so what went wrong?

Digging deeper, we realized we had exhausted our connection pool. But how? We were using Spring Boot with the default
HikariCP configuration. That day, I dove deep into how HikariCP works internally, and this blog is the result of that
learning.

## Problem

When using Spring Boot, developers often rely on the default database connection pool — HikariCP — without understanding
how it manages connections internally. This leads to common issues:

* Application hangs under load
* Exceptions like `Connection is not available`
* Inefficient use of connections

These problems arise due to incorrect assumptions about connection lifecycle, misconfigured pool size, and a lack of
awareness of how HikariCP operates.

## Solution

Understanding how HikariCP works internally and how it integrates with Spring Boot can help us:

* Prevent connection exhaustion
* Improve performance
* Tune the pool size appropriately
* Handle failure gracefully

Let’s explore this in detail.

## Multiple Examples in Detailed Fashion with Explanation

### 1. How HikariCP Integrates with Spring Boot

When you add a dependency like `spring-boot-starter-data-jpa` or `spring-boot-starter-jdbc`, Spring Boot auto-configures
a DataSource. If HikariCP is available on the classpath, it is selected as the default connection pool.

```xml
<dependency>
    <groupId>com.zaxxer</groupId>
    <artifactId>HikariCP</artifactId>
</dependency>
```

Spring Boot creates and configures an instance of `HikariDataSource` during startup using properties defined in
`application.properties` or `application.yml`.

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/mydb
    username: user
    password: pass
    hikari:
      maximum-pool-size: 10
      minimum-idle: 2
      connection-timeout: 30000
      idle-timeout: 600000
```

### 2. When Does HikariCP Create a Connection?

HikariCP creates connections lazily or eagerly based on configuration. Here’s how:

* **At Startup**: `minimumIdle` number of connections are created and kept in the pool.
* **During Runtime**: When the application needs more connections, HikariCP creates new connections up to the
  `maximumPoolSize`.
* **Borrowing a Connection**: When `DataSource.getConnection()` is called, HikariCP gives an available connection or
  waits for one if none are free.

### 3. What Happens If a Connection Is Not Available?

If all connections are in use and the pool size has reached `maximumPoolSize`, HikariCP will wait for a connection to
become available. This is governed by the `connectionTimeout` property.

If no connection becomes available within that time, an exception like this is thrown:

```shell
SQLTransientConnectionException: HikariPool-1 - Connection is not available, request timed out after 30000ms.
```

### 4. Handling Connection Timeouts

To prevent this:

* Ensure proper pool sizing
* Close connections after use (using try-with-resources or frameworks like Spring)
* Monitor connection pool metrics

```java
try(Connection conn = dataSource.getConnection()){
        // use connection
}
```

### 5. Monitoring the Pool

Enable metrics in Spring Boot with Actuator:

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

Access `/actuator/metrics/hikaricp.connections.active`, `.idle`, `.usage` to get insights.

## Best Practices

* Set `maximumPoolSize` based on database capabilities and app requirements
* Always close ResultSet, Statement, and Connection
* Use Spring's `@Transactional` correctly to manage connection boundaries
* Monitor and alert on pool usage
* Use connection leak detection (`leakDetectionThreshold`)

## Anti Patterns

* Keeping connections open for long periods
* Not closing ResultSet/Statement/Connection explicitly
* Setting `maximumPoolSize` too high without understanding database limits
* Ignoring connection timeouts and assuming unlimited availability
* Running long-blocking operations within transactions

## Final Thoughts

Understanding how HikariCP works with Spring Boot is essential for building resilient and performant applications. It’s
not just a configuration detail — it’s a critical piece of infrastructure. Tune it with care, observe it in production,
and your app will thank you under load.

## Summary

* Spring Boot uses HikariCP as the default connection pool
* Connections are created lazily or eagerly based on configuration
* If all connections are in use, HikariCP waits for `connectionTimeout`
* Proper sizing and resource handling is key to avoiding connection issues
* Use monitoring and best practices to tune and manage the pool

## Good Quote

> "The bitterness of poor performance remains long after the sweetness of quick configuration is forgotten."

That's it for today, will meet in next episode.  
Happy coding :grinning:
