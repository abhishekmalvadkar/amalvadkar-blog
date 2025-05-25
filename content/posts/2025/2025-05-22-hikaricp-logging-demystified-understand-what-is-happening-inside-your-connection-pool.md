---
title: 'HikariCP Logging Demystified: Understand What is Happening Inside Your Connection Pool'
author: Abhishek
type: post
date: 2025-05-22T12:29:04+05:30
url: "/hikaricp-logging-demystified-understand-what-is-happening-inside-your-connection-pool/"
toc: true
draft: false
categories: [ "spring boot" ]
tags: [ "spring-transaction" , "connection-pool", "hikari-cp" ]
---

It was a peaceful Tuesday morning. Our team was just recovering from a weekend release when we started getting pings
from the production support team. The API response times had gone through the roof. All eyes turned to the usual
suspects — memory leaks, infinite loops, and GC pauses. But everything looked normal.

Then someone checked the database connection pool.

Boom! HikariCP was exhausted — not a single connection available. But why? The logs weren’t very helpful. We had no
visibility into how HikariCP was behaving.

That was the beginning of our journey to understand and master **HikariCP logging**.

## Problem: Lack of Visibility into HikariCP Behavior

HikariCP is a high-performance JDBC connection pool — fast, lightweight, and robust. But by default, it's relatively
silent. It doesn’t scream when something goes wrong, like:

* Connections not being released
* Pool exhaustion
* Long connection acquisition times
* Failures in acquiring or releasing connections

Developers often find themselves in the dark, especially during production issues, because they didn't configure or
understand **HikariCP's logging capabilities**.

## Solution: Enable and Understand HikariCP Logging

To solve this, we need to:

1. **Enable logging at the right level**
2. **Know which classes log what**
3. **Understand how to interpret these logs**
4. **Optionally hook in metrics for observability**

Logging gives us the real-time story of the pool’s lifecycle: connections being created, borrowed, returned, or leaked.

## Examples: HikariCP Logging in Detail

### Example 1: Basic Logging with `INFO` Level

**Dependencies**: If using SLF4J with Logback or Log4j2

```properties
# application.properties or logback.xml
logging.level.com.zaxxer.hikari=INFO
```

You’ll now see logs like:

```shell
HikariPool-1 - Starting...
HikariPool-1 - Start completed.
```

**What it means**: The pool started, and it's ready to serve connections.

### Example 2: Logging Pool Behavior at `DEBUG` Level

```properties
logging.level.com.zaxxer.hikari=DEBUG
```

This gives much more insight:

```shell
HikariPool-1 - Before cleanup stats (total=10, active=2, idle=8, waiting=0)
HikariPool-1 - After cleanup stats (total=10, active=2, idle=8, waiting=0)
```

**Explanation**:

* `total`: total connections in the pool
* `active`: in-use connections
* `idle`: available connections
* `waiting`: threads waiting for a connection

You can now correlate API spikes with `waiting > 0`, a sign of pool exhaustion.

### Example 3: Detecting Connection Leaks

Add this to detect if a connection is not returned in time:

```properties
spring.datasource.hikari.leak-detection-threshold=30000  # 30 seconds
```

If a thread holds a connection for more than 30s, you get:

```shell
Connection leak detection triggered for com.zaxxer.hikari.pool.ProxyConnection@7c3df479, stack trace follows...
```

This tells you **exactly where** the connection wasn’t returned.

### Example 4: Log Connection Lifecycle (Advanced)

Add a custom `SLF4J` logger for `HikariPool` internals:

```properties
logging.level.com.zaxxer.hikari.pool.PoolBase=TRACE
```

Now you’ll see logs like:

```shell
HikariPool-1 - Added connection conn123: url=jdbc:mysql://localhost:3306/db (open)
HikariPool-1 - Connection conn123 added to pool
```

Use this to monitor:

* When connections are added to the pool
* When and why new connections are created

## Best Practices

1. **Set appropriate log levels for environments**:

    * `INFO` in production
    * `DEBUG`/`TRACE` in development/staging

2. **Always enable leak detection** in lower environments

3. **Integrate Hikari metrics** with Micrometer/Prometheus/Grafana for dashboards

4. **Use maxLifetime, idleTimeout, and connectionTimeout wisely** to avoid zombie or exhausted connections

5. **Avoid blind retries** when getting connection timeouts — always investigate!

## Anti-Patterns

1. **Setting log level to TRACE in production** — floods logs, affects performance

2. **Disabling leak detection entirely** — you’ll never know what’s stuck

3. **Hardcoding pool sizes without understanding the DB’s limit** — may overload your database

4. **Not monitoring metrics** — logging helps, but metrics give the big picture

5. **Relying solely on logs without context** — logs tell *what* happened, not *why* it happened

## Final Thoughts

HikariCP is like a Ferrari — fast and efficient, but you need to know how to drive it. Logging is the dashboard that
tells you how the engine is running. Without it, you're flying blind.

Don't wait for a production incident to understand your connection pool. Turn on the lights today.

## Summary

* HikariCP is silent by default — enable logging to see what’s happening
* Use appropriate log levels (`INFO`, `DEBUG`, `TRACE`) for the right environments
* Leak detection is a life-saver during debugging
* Understanding logs helps diagnose performance issues, pool exhaustion, and connection leaks
* Combine logs with metrics for full observability

## Good Quote

> "Logs tell the story of your app’s soul. When something breaks, they’re the voice that whispers the truth."   
> – Anonymous DevOps Engineer

That's it for today, will meet in next episode.  
Happy coding :grinning:
