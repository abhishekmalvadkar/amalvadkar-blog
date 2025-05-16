---
title: 'Spring Boot Tomcat Request Handling: Thread Management Under Load'
author: Abhishek
type: post
date: 2025-05-16T11:03:18+05:30
url: "/spring-boot-tomcat-request-handling-thread-management-under-load/"
toc: true
draft: false
categories: [ "system design", "spring boot" ]
tags: [ "high-level-design" ]
---

It was a quiet morning until our product team deployed a new feature to production. Moments later, monitoring dashboards
lit up—CPU spiked, response times soared, and users started reporting timeouts. The culprit? A spike in concurrent user
traffic triggered by a marketing campaign. Our Spring Boot application, running on an embedded Tomcat server, couldn't
handle the load. Threads were maxed out, and requests started queuing or timing out.

This blog will unravel how Spring Boot handles HTTP requests through Tomcat, how threads are allocated, what happens
under load, and how you can prepare your application to avoid meltdowns.

## Problem

Spring Boot, by default, uses an embedded Apache Tomcat server. Most developers use it out-of-the-box without
understanding how requests are processed or how threads are allocated. Under normal load, everything seems fine. But
under concurrent high load:

* Requests are slower
* Threads get exhausted
* Queues start filling
* Eventually, requests are dropped or time out

Without tuning thread pools and connection settings, Tomcat cannot scale effectively.

## Solution

Tomcat uses a thread pool to handle incoming HTTP requests. Understanding and configuring this pool properly is key to
scaling your application. Here’s how it works:

1. **Tomcat creates a thread pool using the `Executor` or `Connector` configuration.**
2. **Each incoming request is assigned to an available thread from the pool.**
3. **If all threads are busy, requests are queued.**
4. **If the queue is full, further requests are rejected.**

By configuring the maximum number of threads and queue size, you can handle more concurrent users gracefully.

## How Tomcat Handles a Request (Thread Lifecycle)

Here is a breakdown of how a request is handled in Tomcat with respect to threading:

### 1. Incoming Request

When a client sends an HTTP request, it hits Tomcat's **Connector**, which is responsible for listening on a TCP port (
e.g., 8080).

### 2. Acceptor Thread

The **Acceptor Thread** of the Connector picks up the connection from the socket. If a thread from the worker pool is
available, it assigns the socket to a worker thread.

### 3. Worker Thread Pool

The **worker thread** (from Tomcat's thread pool) processes the request by:

* Parsing headers
* Passing control to the appropriate servlet (Spring DispatcherServlet)
* Executing controller/business logic
* Returning a response

### 4. Thread Release

Once the request is processed, the thread is released back to the pool for reuse.

### Key Components

* **Connector**: Listens for incoming connections.
* **Acceptor Thread**: Picks up socket connections.
* **Worker Threads**: Execute actual request logic.

## What Happens When the Queue Times Out?

When all worker threads are busy and the number of pending requests exceeds the `accept-count` (i.e., the request queue size), Tomcat starts rejecting new requests. Here's how it unfolds:

1. **Thread Pool Saturation**: All threads (up to `max-threads`) are actively handling requests.
2. **Queue Fill-up**: New incoming requests wait in a queue (up to `accept-count`).
3. **Timeout or Rejection**:

    * If the queue is full and new requests come in, they are immediately rejected with an HTTP 503 (Service Unavailable).
    * If a request sits too long in the queue and the client-side timeout expires (or load balancer timeout), the client gives up and the request is dropped.

### Real-World Scenario

Imagine your API has:

```properties
server.tomcat.max-threads=200
server.tomcat.accept-count=100
```

* Total capacity = 200 active + 100 queued
* On the 301st concurrent request, Tomcat returns 503 unless a running thread becomes free

## Examples and Detailed Explanation

### Example 1: Default Spring Boot Setup

By default, Spring Boot uses:

```yaml
server.tomcat.threads.max=200
server.tomcat.threads.min-spare=10
```

This means:

* Maximum of 200 request-handling threads
* Minimum of 10 threads always kept ready

If you get 500 concurrent requests and each takes 1 second:

* 200 are handled concurrently
* 300 go into a queue or wait for thread availability

### Example 2: Load Testing with JMeter

Suppose we load test with 1000 users hitting a REST API:

* Each request takes 500ms to complete
* Tomcat handles 200 concurrently
* Remaining 800 pile up
* Queue fills, response times spike, errors start appearing

### Example 3: Thread Configuration

Update `application.properties`:

```properties
server.tomcat.max-threads=300
server.tomcat.accept-count=100
```

Explanation:

* `max-threads`: maximum request processing threads
* `accept-count`: max queued connections before rejecting

With this setup:

* 300 threads can process requests concurrently
* 100 more requests can wait in the queue
* 401st concurrent request gets rejected (HTTP 503)

### Example 4: Custom Executor

You can define a custom thread pool:

```java

@Bean
public TomcatServletWebServerFactory tomcatFactory() {
    return new TomcatServletWebServerFactory() {
        @Override
        protected void customizeConnector(Connector connector) {
            ProtocolHandler handler = connector.getProtocolHandler();
            if (handler instanceof AbstractProtocol) {
                AbstractProtocol<?> protocol = (AbstractProtocol<?>) handler;
                protocol.setMaxThreads(300);
                protocol.setAcceptCount(100);
            }
        }
    };
}
```

This allows fine-tuning through code.

## Best Practices

* **Load test early**: Simulate realistic traffic using tools like JMeter or Gatling
* **Tune thread settings**: Adjust `max-threads` and `accept-count` based on benchmarks
* **Use connection pooling**: For DB and external systems
* **Profile thread usage**: Use JVisualVM or Thread Dumps
* **Implement backpressure**: Don’t overwhelm Tomcat with endless input
* **Monitor thread usage**: Integrate Prometheus + Grafana for metrics

## Anti-Patterns

* **Blocking I/O**: Long DB/API calls block threads, reducing concurrency
* **Synchronous long tasks**: Doing heavy computation in controller layer
* **Ignoring timeouts**: Can leave threads hanging
* **Improper error handling**: Letting threads crash on exceptions

## Final Thoughts

Understanding the internals of Tomcat request handling isn’t just academic—it’s essential for building resilient,
performant Spring Boot applications. Whether you're serving 100 or 10,000 concurrent users, properly managing your
thread pool can make the difference between uptime and downtime.

## Summary

* Tomcat uses a thread pool to process HTTP requests.
* Each request gets a thread; if all are busy, requests queue up.
* Configuration via `max-threads` and `accept-count` is crucial.
* Load test and monitor early in the development cycle.
* Avoid thread-blocking operations in request-handling layers.

## Good Quote

> "Scalability isn't about how fast you can go, but how gracefully you can slow down under pressure."   
> – Unknown

That's it for today, will meet in next episode.  
Happy system design :grinning: