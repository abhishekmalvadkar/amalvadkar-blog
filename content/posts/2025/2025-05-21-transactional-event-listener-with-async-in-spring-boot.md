---
title: 'Transactional Event Listener With @Async in Spring Boot'
author: Abhishek
type: post
date: 2025-05-21T11:16:55+05:30
url: "/transactional-event-listener-with-async-in-spring-boot/"
toc: true
draft: false
categories: [ "spring boot" ]
tags: [ "spring-events" ]
---

A few months ago, while building a customer onboarding system at my workplace, we faced a peculiar issue. The business
logic included sending a welcome email to the customer as soon as their account was created. Naturally, we plugged in an
event system to decouple the email functionality from the main transaction.

Everything worked perfectly during testing, but in production, users started complaining that they didn't receive the
welcome email immediately or sometimes not at all. We started debugging and found something odd — the email sending
event listener was firing even when the transaction for user creation failed! 😱

That's when we learned about `@TransactionalEventListener` in Spring and its magic when combined with `@Async`. This
blog is a deep dive into how you can reliably and asynchronously trigger events only after a transaction successfully
commits in Spring Boot.

## Problem

Spring's standard `@EventListener` mechanism works great for decoupling components, but it has limitations when used
within transactional boundaries.

### Common problems:

1. **Event fires before transaction commits:**

    * If you fire an event inside a transactional method, the event is processed immediately.
    * If the transaction later rolls back, your event (e.g., email, notification, external API call) already executed —
      leading to inconsistency.

2. **Blocking behavior:**

    * Listeners executing synchronously block the main transaction thread.
    * This is inefficient when the listener does time-consuming tasks like sending emails or updating external services.

## Solution

Spring provides a powerful annotation: `@TransactionalEventListener`, which ensures that the event handler only executes
**after a successful transaction commit**.

Combine this with `@Async`, and you get the best of both worlds:

* **Transactional safety**
* **Non-blocking execution**

## Multiple Examples in Detailed Fashion with Explanation

Let's break it down step-by-step with real-world-style examples.

### 1. Setup Spring Boot Project

Add dependencies in `pom.xml`:

```xml
<dependency>
   <groupId>org.springframework.boot</groupId>
   <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>

<dependency>
<groupId>org.springframework.boot</groupId>
<artifactId>spring-boot-starter-web</artifactId>
</dependency>

<dependency>
<groupId>org.springframework.boot</groupId>
<artifactId>spring-boot-starter-mail</artifactId>
</dependency>

<dependency>
<groupId>org.springframework.boot</groupId>
<artifactId>spring-boot-starter-aop</artifactId>
</dependency>
```

Also, add:

```java

@EnableAsync
@SpringBootApplication
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
```

### 2. Define the Event

```java
public class UserCreatedEvent {
    private final Long userId;

    public UserCreatedEvent(Long userId) {
        this.userId = userId;
    }

    public Long getUserId() {
        return userId;
    }
}
```

### 3. Publish the Event Inside a Transaction

```java

@Service
public class UserService {

    private final UserRepository userRepository;
    private final ApplicationEventPublisher eventPublisher;

    public UserService(UserRepository userRepository, ApplicationEventPublisher eventPublisher) {
        this.userRepository = userRepository;
        this.eventPublisher = eventPublisher;
    }

    @Transactional
    public void registerUser(String name, String email) {
        User user = new User(name, email);
        userRepository.save(user);

        // Publish the event
        eventPublisher.publishEvent(new UserCreatedEvent(user.getId()));

        // Simulate a possible exception
        // throw new RuntimeException("DB insert failed");
    }
}
```

### 4. Handle the Event Asynchronously, After Commit

```java

@Component
public class UserCreatedListener {

    @Async
    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleUserCreated(UserCreatedEvent event) {
        // Simulate sending email
        System.out.println("Sending welcome email to user: " + event.getUserId());
        // sendEmail(userEmail); // logic to send email
    }
}
```

### Explanation:

* `@TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)` ensures that the method runs **only after** the
  transaction is successfully committed.
* `@Async` makes sure the method runs on a separate thread, **not blocking** the main transaction.

### 5. Enable Async Configuration

```java

@Configuration
@EnableAsync
public class AsyncConfig {

    @Bean(name = "taskExecutor")
    public Executor taskExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(2);
        executor.setMaxPoolSize(5);
        executor.setQueueCapacity(100);
        executor.setThreadNamePrefix("AsyncExecutor-");
        executor.initialize();
        return executor;
    }
}
```

## Best Practices

1. **Use specific event classes** instead of generic `Object` events to increase type safety.
2. **Keep listeners idempotent** to avoid issues if they are retried or triggered multiple times.
3. **Avoid modifying database state in listeners** — keep them read-only or external-action-focused.
4. **Separate long-running logic** out of the transactional method using events.
5. **Gracefully handle exceptions** inside `@Async` methods to prevent thread termination.

## Anti-Patterns

1. **Using `@Async` without proper executor configuration**:

    * This may silently fail or execute synchronously depending on context.

2. **Publishing events outside transaction boundaries**:

    * If you do this before the transaction commits, it defeats the purpose of `@TransactionalEventListener`.

3. **Writing to the database in the listener**:

    * You're no longer in the original transaction. A new transaction might be required and could lead to
      inconsistencies.

4. **Forgetting `@EnableAsync`**:

    * This results in `@Async` having no effect — your code runs synchronously.

## Final Thoughts

The combination of `@TransactionalEventListener` and `@Async` is a powerful pattern in Spring Boot for building
reactive, resilient, and consistent applications.

It helps achieve separation of concerns, better performance, and fewer headaches in complex transactional flows — all
without bringing in heavy infrastructure.

Use this pattern wisely and always test your transactional scenarios carefully.

## Summary

* Spring's event system is powerful but must be used carefully with transactions.
* `@TransactionalEventListener` ensures listener executes **only after commit**.
* `@Async` decouples and improves performance.
* Combine both for clean, reliable event-driven systems.

> "The best way to predict the future is to decouple and commit."   
> — Unknown

That's it for today, will meet in next episode.  
Happy coding 😃
