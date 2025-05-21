---
title: 'How Spring Boot @Async Works With Default SimpleAsyncTaskExecutor'
author: Abhishek
type: post
date: 2025-05-21T11:39:32+05:30
url: "/how-spring-boot-async-works-with-default-simpleasynctaskexecutor/"
toc: true
draft: false
categories: [ "spring boot" ]
tags: [ "spring-async" ]
---

A few years ago, while working on a microservices-based ecommerce application, our team faced an issue during a flash
sale event. We noticed that user-facing APIs were slowing down because certain background operations like sending
emails, logging audit data, and calculating recommendations were happening synchronously. As a result, users had to wait
for all these tasks to complete before receiving a response.

One of our junior developers asked, "Why are we not offloading these long-running tasks to a separate thread?" It was a
valid question—and the perfect time to introduce Spring Boot’s `@Async` annotation. We had heard of it but never used it
in production. To our surprise, using `@Async` with Spring Boot's default `SimpleAsyncTaskExecutor` provided an
immediate performance boost.

Let's dive into how `@Async` works in Spring Boot, especially with the default executor.

## Problem

In modern applications, certain operations don't need to block the user response. For example:

* Sending a welcome email after user registration
* Logging user activities to a file or database
* Processing images or files uploaded by the user

Executing these operations synchronously causes the following issues:

* Increased response time
* Poor user experience
* Inefficient resource usage

What we need is a way to *fire and forget* these background tasks without impacting the main application thread.

## Solution

Spring Boot provides a powerful abstraction to handle such scenarios using the `@Async` annotation. When applied to a
method, it runs that method in a separate thread without blocking the caller.

By default, Spring Boot uses `SimpleAsyncTaskExecutor` if no custom executor is defined. This executor:

* Spawns a new thread for every task
* Does **not** reuse threads (no thread pool)
* Is suitable for lightweight tasks

### How to Enable It

You must enable async support using `@EnableAsync` in a Spring configuration class:

```java

@Configuration
@EnableAsync
public class AsyncConfig {
}
```

Then, annotate any method with `@Async`:

```java

@Service
public class NotificationService {

    @Async
    public void sendWelcomeEmail(String email) {
        // Simulate delay
        Thread.sleep(3000);
        System.out.println("Email sent to: " + email);
    }
}
```

Now, calling `sendWelcomeEmail()` won’t block the main thread.

## Multiple Examples in Detailed Fashion with Explanation

### 1. Fire-and-Forget Logging

```java

@Service
public class AuditService {

    @Async
    public void logUserAction(String username, String action) {
        // Save to file or database
        System.out.println("Logging: " + username + " performed " + action);
    }
}
```

```java

@RestController
public class UserController {

    private final AuditService auditService;

    public UserController(AuditService auditService) {
        this.auditService = auditService;
    }

    @PostMapping("/update-profile")
    public ResponseEntity<String> updateProfile(@RequestBody User user) {
        // Business logic
        auditService.logUserAction(user.getUsername(), "Updated Profile");
        return ResponseEntity.ok("Profile updated successfully");
    }
}
```

**Explanation**: The user receives an immediate response while logging happens in the background.

### 2. Async Method Returning CompletableFuture

```java

@Service
public class ReportService {

    @Async
    public CompletableFuture<String> generateReport() throws InterruptedException {
        Thread.sleep(5000); // simulate delay
        return CompletableFuture.completedFuture("Report generated");
    }
}
```

```java

@RestController
public class ReportController {

    private final ReportService reportService;

    public ReportController(ReportService reportService) {
        this.reportService = reportService;
    }

    @GetMapping("/report")
    public CompletableFuture<ResponseEntity<String>> getReport() throws InterruptedException {
        return reportService.generateReport()
                .thenApply(ResponseEntity::ok);
    }
}
```

**Explanation**: The controller can return a `CompletableFuture` so Spring MVC will wait for it to complete without
blocking a servlet thread.

### 3. Exception Handling in Async Methods

```java

@Service
public class EmailService {

    @Async
    public void sendEmail(String to) {
        if (to == null) throw new IllegalArgumentException("Email can't be null");
        // Send email logic
    }
}
```

**Important Note**: Exceptions thrown from `@Async` void methods are swallowed unless you set up an
`AsyncUncaughtExceptionHandler`.

```java

@Configuration
@EnableAsync
public class AsyncConfig implements AsyncConfigurer {

    @Override
    public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
        return (throwable, method, objects) -> {
            System.err.println("Exception in async method: " + method.getName());
            throwable.printStackTrace();
        };
    }
}
```

## Best Practices

* Use `@Async` for lightweight, non-blocking operations
* Return `CompletableFuture<T>` or `Future<T>` if you need the result
* Handle exceptions with `AsyncUncaughtExceptionHandler`
* Log important async operations for traceability
* Monitor thread creation with `SimpleAsyncTaskExecutor` to avoid uncontrolled spawning

## Anti Patterns

* **Blocking Calls in Async Method**: If the async method performs blocking operations, it defeats the purpose of async.
* **Calling `@Async` Methods Internally**: Calling an async method from within the same class won’t be proxied, so it
  runs synchronously.
* **Heavy Tasks with Default Executor**: `SimpleAsyncTaskExecutor` creates new threads for each task; avoid using it for
  CPU-heavy or high-volume jobs.
* **Missing `@EnableAsync`**: Forgetting this annotation will cause all `@Async` calls to be synchronous.

## Final Thoughts

The `@Async` annotation is a hidden gem in Spring Boot that can drastically improve performance and responsiveness if
used correctly. While the default `SimpleAsyncTaskExecutor` is great for quick wins and prototyping, always evaluate
your threading needs and consider a custom `ThreadPoolTaskExecutor` for better control and resource management in
production systems.

Once you start using `@Async`, you’ll wonder why you didn’t adopt it earlier for all those background tasks.

## Summary

* `@Async` allows non-blocking execution of methods
* Requires `@EnableAsync` configuration
* Uses `SimpleAsyncTaskExecutor` by default
* Ideal for lightweight background tasks
* Avoid using it for heavy operations without a custom executor
* Proper exception handling and logging are essential

## Good Quote

> "The best way to predict the future is to implement it—asynchronously."   
> — Anonymous



That's it for today, will meet in next episode.  
Happy coding :grinning:
