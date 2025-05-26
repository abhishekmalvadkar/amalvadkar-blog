---
title: 'Structured Logging in Java Spring Boot'
author: Abhishek
type: post
date: 2025-05-26T14:50:01+05:30
url: "/structured-logging-in-java-spring-boot/"
toc: true
draft: false
categories: [ "spring boot" ]
tags: [ "logging" ]
---

It was a Friday evening, and our production support team was dealing with a critical issue. A customer had reported an
intermittent problem with placing orders through our Spring Boot application. We had logs in place, but they were the
traditional unstructured kind: long strings of information, inconsistently formatted, and difficult to parse. Grepping
through gigabytes of log files on ELK (Elasticsearch, Logstash, Kibana) wasn't helping. We spent hours trying to
reconstruct what had happened, looking for a needle in a haystack.

Finally, a senior engineer sighed and said, "We need structured logging. This wouldn't have taken more than 10 minutes
with proper logging keys."

And that’s how we started our journey toward structured logging.

## Problem

Traditional logging practices involve writing human-readable strings into log files. While this helps during local
debugging, it becomes a nightmare when:

* Logs are distributed across multiple services
* Services are deployed on multiple instances or containers
* You need to correlate events across systems
* You’re parsing logs in centralized logging platforms (like ELK, Splunk, or Datadog)

Unstructured logs look like this:

```text
INFO  OrderService: Order placed for customerId=12345 with totalAmount=456.78
```

These logs are hard to query, filter, or visualize unless you're writing complex regex patterns.

## Solution: Structured Logging

Structured logging refers to recording logs as key-value pairs in a consistent and machine-parsable format like JSON.
Instead of plain text, logs are structured like this:

```json
{
  "timestamp": "2025-05-26T12:34:56Z",
  "level": "INFO",
  "service": "order-service",
  "message": "Order placed",
  "customerId": 12345,
  "totalAmount": 456.78,
  "orderId": "ORD7890"
}
```

This enables powerful querying, filtering, aggregation, and alerting in centralized platforms. You can search all orders
for a particular `customerId`, filter logs by `orderId`, or trace the lifecycle of a request across services.

## Multiple Examples in Detailed Fashion

### 1. Adding Structured Logging in Spring Boot using Logstash Encoder

**Step 1: Add dependency in `pom.xml`**

```xml

<dependency>
    <groupId>net.logstash.logback</groupId>
    <artifactId>logstash-logback-encoder</artifactId>
    <version>7.4</version>
</dependency>
```

**Step 2: Configure `logback-spring.xml`**

```xml

<configuration>
    <include resource="org/springframework/boot/logging/logback/base.xml"/>

    <appender name="JSON" class="net.logstash.logback.appender.LoggingEventCompositeJsonEncoder">
        <encoder class="net.logstash.logback.encoder.LoggingEventCompositeJsonEncoder">
            <providers>
                <timestamp>
                    <fieldName>timestamp</fieldName>
                </timestamp>
                <pattern>
                    <pattern>
                        {
                        "level": "%level",
                        "logger": "%logger",
                        "thread": "%thread",
                        "message": "%message"
                        }
                    </pattern>
                </pattern>
                <mdc/>
            </providers>
        </encoder>
    </appender>

    <root level="INFO">
        <appender-ref ref="JSON"/>
    </root>
</configuration>
```

**Step 3: Add context information using MDC (Mapped Diagnostic Context)**

```java
import org.slf4j.MDC;

public void processOrder(Order order) {
    MDC.put("orderId", order.getId());
    MDC.put("customerId", String.valueOf(order.getCustomerId()));

    log.info("Order placed successfully");

    MDC.clear(); // Always clear to avoid context leakage
}
```

### 2. Tracing Requests Across Microservices

Add a unique `correlationId` in MDC at the beginning of each HTTP request.

**Using a Spring Filter:**

```java

@Component
public class CorrelationIdFilter extends OncePerRequestFilter {
    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        String correlationId = UUID.randomUUID().toString();
        MDC.put("correlationId", correlationId);
        response.setHeader("X-Correlation-Id", correlationId);
        try {
            filterChain.doFilter(request, response);
        } finally {
            MDC.clear();
        }
    }
}
```

This correlation ID helps trace a request’s journey through all microservices.

### 3. Custom Logger Wrapper

You can wrap your logger to always enrich logs with MDC data:

```java
public class StructuredLogger {
    private final Logger logger;

    public StructuredLogger(Class<?> clazz) {
        this.logger = LoggerFactory.getLogger(clazz);
    }

    public void info(String message, Map<String, Object> context) {
        context.forEach((key, value) -> MDC.put(key, value.toString()));
        logger.info(message);
        MDC.clear();
    }
}
```

## Best Practices

* Always clear MDC context after the request completes.
* Use consistent keys like `orderId`, `customerId`, `correlationId`.
* Include environment info (like `env`, `instanceId`) to identify logs.
* Centralize your logger config and avoid repetitive MDC code.
* Combine with observability tools like Zipkin or OpenTelemetry.
* Log structured JSON and ship it to ELK or similar for dashboards.
* Avoid logging sensitive data (PII, passwords, tokens).

## Anti-Patterns

* Logging full objects without sanitizing them.
* Using different keys for the same concept (`custId` vs `customerId`).
* Forgetting to clear MDC context (can lead to memory leaks or incorrect context).
* Ignoring correlation ID in async executions.
* Logging exceptions without stack traces (`log.error("Failed", e)` is better than `log.error("Failed")`).

## Final Thoughts

Structured logging isn’t just about fancy formatting. It’s a powerful observability tool. When implemented correctly, it
transforms debugging and monitoring from a painful task into a precise, queryable, and reliable process. As your
application scales, structured logging is no longer optional—it becomes essential.

## Summary

* Traditional logs don’t scale with complexity.
* Structured logging improves observability, filtering, and correlation.
* MDC and JSON format are key tools in Java Spring Boot.
* Avoid anti-patterns and follow best practices to gain full value.

> "Logs are the footprints of your application. Make sure they leave a readable, consistent trail."   
> — Unknown

That's it for today, will meet in next episode.

Happy coding :grinning:
