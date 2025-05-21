---
title: 'Mastering @Async in Spring Boot With Exception Handling'
author: Abhishek
type: post
date: 2025-05-21T12:02:54+05:30
url: "/mastering-async-in-spring-boot-with-exception-handling/"
toc: true
draft: false
categories: [ "spring boot" ]
tags: [ "spring-async" ]
---

It was a regular Tuesday morning at our fintech company. We were onboarding a major client, and the system had to send
thousands of welcome emails asynchronously to their users. We proudly deployed our well-tested Spring Boot application
that used the `@Async` annotation for sending emails without blocking the main thread.

Everything seemed smooth... until it wasn’t.

Despite successful REST API responses, users were not receiving emails. We checked the logs and saw no errors. What
happened?

After hours of debugging, we realized something critical: exceptions inside our `@Async` methods were silently failing.
We weren’t handling exceptions properly in async execution, and that caused us real-world embarrassment.

This incident made us rethink and deeply understand the inner workings of `@Async` in Spring Boot—especially how to
handle exceptions.

Let's dive into this journey.

## Problem

The `@Async` annotation in Spring Boot allows methods to run in a separate thread, enabling non-blocking behavior.
However, it introduces a critical challenge:

**Exceptions thrown in `@Async` methods are not propagated to the caller and can easily go unnoticed.**

Why?

* Async methods are executed in a different thread.
* If exceptions occur, they're logged (if at all), but not thrown back to the main thread.
* This can silently fail critical operations (like sending emails, updating remote systems, etc.)

## Solution

Spring provides mechanisms to handle exceptions in async methods:

1. Use `AsyncUncaughtExceptionHandler` for `void` methods.
2. Return a `Future`, `CompletableFuture`, or `ListenableFuture` and handle exceptions using their APIs.
3. Use custom thread pool executors to monitor and log exceptions better.

## Multiple Examples in Detail

### Example 1: Basic Usage of `@Async`

```java

@Service
public class EmailService {

    @Async
    public void sendWelcomeEmail(String email) {
        // Simulate error
        throw new IllegalStateException("Failed to send email to " + email);
    }
}
```

Calling this method won't throw an exception in the controller:

```java

@RestController
public class EmailController {
    @Autowired
    private EmailService emailService;

    @PostMapping("/send")
    public ResponseEntity<String> sendEmail(@RequestParam String email) {
        emailService.sendWelcomeEmail(email);
        return ResponseEntity.ok("Triggered async email.");
    }
}
```

**Problem**: Exception is swallowed.

### Example 2: Handling Exception with `AsyncUncaughtExceptionHandler`

```java

@Configuration
@EnableAsync
public class AsyncConfig implements AsyncConfigurer {

    @Override
    public Executor getAsyncExecutor() {
        return Executors.newCachedThreadPool();
    }

    @Override
    public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
        return (ex, method, params) -> {
            System.err.println("Exception in async method: " + method.getName());
            System.err.println("Message: " + ex.getMessage());
        };
    }
}
```

### Example 3: Using `CompletableFuture` with Exception Handling

```java

@Service
public class EmailService {

    @Async
    public CompletableFuture<String> sendWelcomeEmail(String email) {
        if (email.endsWith("@fail.com")) {
            throw new IllegalArgumentException("Invalid email");
        }
        return CompletableFuture.completedFuture("Success");
    }
}

@RestController
public class EmailController {
    @Autowired
    private EmailService emailService;

    @PostMapping("/send-safe")
    public ResponseEntity<String> sendSafe(@RequestParam String email) {
        try {
            CompletableFuture<String> result = emailService.sendWelcomeEmail(email);
            return ResponseEntity.ok(result.get());
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error: " + e.getCause().getMessage());
        }
    }
}
```

### Example 4: Custom Executor with Exception Logging

```java

@Configuration
@EnableAsync
public class AsyncConfig implements AsyncConfigurer {

    @Override
    public Executor getAsyncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(5);
        executor.setQueueCapacity(500);
        executor.setThreadNamePrefix("AsyncExecutor-");
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }

    @Override
    public AsyncUncaughtExceptionHandler getAsyncUncaughtExceptionHandler() {
        return (ex, method, params) -> {
            System.err.println("Async error in method: " + method.getName());
        };
    }
}
```

## Best Practices

* Always return a `CompletableFuture` if possible to allow result/error handling.
* Use `@EnableAsync` only in config class, not in multiple places.
* Monitor and tune thread pool settings according to workload.
* Log exceptions inside the `AsyncUncaughtExceptionHandler`.
* Ensure proper exception wrapping when calling `.get()` on `Future` or `CompletableFuture`.
* Apply circuit breakers (e.g., Resilience4j) for fault-tolerant async execution.

## Anti-Patterns

* **Using void return type with important business logic** in async methods (hard to trace failures).
* **Ignoring `.get()` result** of `CompletableFuture`, thinking async magic will handle everything.
* **Not configuring custom executor**, leading to default settings and potential thread starvation.
* **Swallowing exceptions** in `@Async` and pretending nothing failed.

## Final Thoughts

Async programming is powerful but dangerous if not handled correctly. Exceptions inside `@Async` methods don’t behave
like normal exceptions, and ignoring them can lead to silent failures. Mastering exception handling in Spring Boot async
methods is crucial for building resilient systems.

Treat async operations as you would treat threads: with discipline, error handling, and clear visibility.

## Summary

* `@Async` enables non-blocking method execution in Spring Boot.
* Exceptions inside async methods are silent unless handled properly.
* Use `AsyncUncaughtExceptionHandler` for `void` methods.
* Prefer returning `CompletableFuture` for better control.
* Configure custom executors for thread tuning and monitoring.
* Follow best practices and avoid common pitfalls.

> "Multithreading is like having a toddler. It’s easy to start, but chaos without supervision."   
> – Unknown



That's it for today, will meet in next episode.  
Happy coding 😀
