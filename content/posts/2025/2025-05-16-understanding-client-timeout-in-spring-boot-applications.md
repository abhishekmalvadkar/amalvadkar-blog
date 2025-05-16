---
title: 'Understanding Client Timeout in Spring Boot Applications'
author: Abhishek
type: post
date: 2025-05-16T11:26:31+05:30
url: "/understanding-client-timeout-in-spring-boot-applications/"
toc: true
draft: false
categories: [ "system design", "spring boot" ]
tags: [ "high-level-design" ]
---

It was a Friday evening, and our team was conducting a load test on our newly built Spring Boot-based microservice. The
client was a browser-based Angular application. Everything looked good until we ramped up the load. Suddenly, some of
the requests started failing. The frontend was showing a spinner forever, and users were getting frustrated. The
operations team raised alarms. Upon investigation, we found that several requests were timing out—not on the server—but
on the client side.

This story sparked a deeper discussion around **client timeouts**—what they are, why they happen, and how to handle them
properly.

## Problem

Client timeout occurs when a client makes a request to the server and doesn't receive a response within the configured
timeout threshold. This could result in:

* HTTP 408 Request Timeout
* No response due to browser timeout
* Broken UX (spinners, retries, errors)
* Cascading failures in microservices

Timeout issues can be tricky to debug, especially under load. They can happen:

* In Angular apps (browser default timeouts or custom HTTP timeout settings)
* In Spring Boot-based clients (e.g., Spring WebClient, RestTemplate, Feign)
* During communication between microservices

## Solution

To fix or prevent client timeout issues:

* Understand and configure **timeout values** correctly on both client and server.
* Implement **graceful degradation** and **retry logic** with backoff.
* Use **timeout observability** (logs, metrics, traces).
* Perform **load testing** to simulate and analyze real-world traffic.

## Examples

### 1. Angular HTTP Client Timeout

Angular's `HttpClient` doesn’t have a default timeout, so long requests can hang indefinitely unless configured:

```typescript
import { HttpClient } from '@angular/common/http';
import { timeout } from 'rxjs/operators';

this.http.get('/api/slow-endpoint')
  .pipe(timeout(5000)) // 5 seconds
  .subscribe(
    data => console.log(data),
    error => console.error('Request timed out', error)
  );
```

### 2. Spring WebClient Timeout Configuration

```java

@Bean
public WebClient webClient() {
    return WebClient.builder()
            .clientConnector(new ReactorClientHttpConnector(
                    HttpClient.create()
                            .responseTimeout(Duration.ofSeconds(3))
            ))
            .build();
}
```

### 3. Spring RestTemplate Timeout

```java

@Bean
public RestTemplate restTemplate() {
    SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
    factory.setConnectTimeout(3000); // 3 sec
    factory.setReadTimeout(3000);
    return new RestTemplate(factory);
}
```

### 4. **Feign Client Timeout**

```yaml
feign:
  client:
    config:
      default:
        connectTimeout: 3000
        readTimeout: 3000
```

### 5. Load Testing with JMeter or Gatling

During load testing:

* Monitor client-side failures
* Identify slow endpoints
* Tune server resources
* Use circuit breakers for failing dependencies

## Best Practices

* Set appropriate **timeouts** on all client types (browser, backend clients).
* Use **fallbacks** and **circuit breakers** (e.g., Resilience4j, Hystrix).
* Use **retry with exponential backoff** for transient failures.
* Configure **timeouts lower than server timeouts** to avoid resource pile-up.
* Use **asynchronous endpoints** or **task queues** for long-running tasks.
* **Log and monitor timeout errors** properly.

## Anti-Patterns

* **No timeout** on HTTP clients (especially in Angular or RestTemplate)
* **Equal client and server timeout** (risk of client waiting forever)
* **Retrying on all errors**, including timeouts (can overload server)
* **Blocking long-running operations** on main thread (e.g., UI thread)
* **Ignoring timeout metrics** during testing or monitoring

## Final Thoughts

Client timeouts are subtle and often neglected until production issues arise. They can significantly affect user
experience and system reliability. Understanding and configuring them well, paired with observability and load testing,
is crucial in building robust applications.

## Summary

* Client timeout occurs when the server takes too long to respond.
* It must be explicitly handled in both frontend and backend clients.
* Configure lower client timeouts than server timeouts.
* Load testing helps catch such issues before production.
* Avoid anti-patterns like no timeout or blind retries.

## Good Quote

> "A fast-failing system is better than a slow-hanging one—fail quickly, recover gracefully."

That's it for today, will meet in next episode.  
Happy system design :grinning: