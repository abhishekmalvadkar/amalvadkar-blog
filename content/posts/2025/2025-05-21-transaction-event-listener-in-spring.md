---
title: 'Transaction Event Listener in Spring'
author: Abhishek
type: post
date: 2025-05-21T11:05:48+05:30
url: "/transaction-event-listener-in-spring/"
toc: true
draft: false
categories: [ "spring boot" ]
tags: [ "spring-events" ]
---

A few months ago, while working on a feature that involved sending confirmation emails after successfully registering a
user, we encountered an odd bug in our Spring Boot application. The registration worked fine, but occasionally, users
would receive confirmation emails even though their registration had failed due to a constraint violation in the
database.

At first, it seemed like a race condition or some misconfiguration in our async task executor. After some deep
debugging, we discovered that the email sending logic was being invoked *before* the database transaction committed
successfully. In other words, the event was being published and handled even if the transaction rolled back.

This led us to a crucial realization: we needed to ensure that certain events only fire *after* a transaction has been
successfully committed. That’s when we discovered `@TransactionalEventListener` in Spring.

## Problem

In transactional systems, especially those using Spring's `@Transactional` annotation, it's common to publish domain
events (like sending emails, updating audit logs, or syncing with another system) after a successful transaction.

However, using `ApplicationEventPublisher` and listening with `@EventListener` does not guarantee that the event will be
processed **only** after the transaction is committed. This can lead to serious bugs such as:

* Sending emails or notifications for data that was never persisted
* Logging or auditing incorrect or incomplete state
* Triggering workflows based on data that ultimately rolled back

## Solution

Spring provides the `@TransactionalEventListener` annotation, which integrates seamlessly with Spring's transaction
management. This annotation allows you to listen for events only *after* the transaction is committed (or rolled back,
depending on your configuration).

This ensures that you react only to successful changes in the database, improving the consistency and reliability of
your application.

## Multiple Examples in Detailed Fashion with Explanation

### Example 1: Sending Email After User Registration

```java
public class UserRegisteredEvent {
    private final String email;

    public UserRegisteredEvent(String email) {
        this.email = email;
    }

    public String getEmail() {
        return email;
    }
}
```

#### Publishing the Event

```java

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ApplicationEventPublisher publisher;

    @Transactional
    public void registerUser(String email) {
        User user = new User(email);
        userRepository.save(user);
        publisher.publishEvent(new UserRegisteredEvent(email));
    }
}
```

#### Listening to the Event

```java

@Component
public class EmailService {

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void handleUserRegisteredEvent(UserRegisteredEvent event) {
        System.out.println("Sending email to: " + event.getEmail());
        // send email logic here
    }
}
```

### Explanation

* The event is published inside a `@Transactional` method.
* The listener method will only be invoked *after* the transaction successfully commits.

### Example 2: Logging Audit After Transaction

```java
public class AuditLogEvent {
    private final String action;

    public AuditLogEvent(String action) {
        this.action = action;
    }

    public String getAction() {
        return action;
    }
}

@Component
public class AuditService {

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
    public void onAuditEvent(AuditLogEvent event) {
        System.out.println("Logging audit action: " + event.getAction());
    }
}
```

### Example 3: Handling Rollback Events

```java

@Component
public class RollbackHandler {

    @TransactionalEventListener(phase = TransactionPhase.AFTER_ROLLBACK)
    public void onRollback(UserRegisteredEvent event) {
        System.out.println("Transaction failed for: " + event.getEmail());
    }
}
```

## Best Practices

* Always use `@TransactionalEventListener` for domain events that should happen only after a successful commit.
* Keep listener logic idempotent and failure-tolerant.
* Avoid complex logic inside listeners; delegate to services where needed.
* Use asynchronous listeners (`@Async`) cautiously and only if necessary.
* Prefer immutable event objects for safety and clarity.

## Anti Patterns

* **Using ************`@EventListener`************ for transactional work**: This can lead to premature execution before
  transaction commits.
* **Doing DB writes inside listeners without transactions**: Can cause inconsistencies.
* **Publishing events outside transaction boundaries**: Events may fire even when the transaction fails.
* **Too many responsibilities in a single listener**: Violates single responsibility and makes debugging harder.

## Final Thoughts

The `@TransactionalEventListener` annotation is a powerful yet underused feature in Spring that helps maintain data
integrity and consistency. It bridges the gap between domain events and transactional guarantees, ensuring side-effects
only occur after a transaction successfully completes.

Adopting this pattern improves code quality, simplifies post-transaction logic, and prevents subtle bugs that are hard
to trace.

## Summary

* `@TransactionalEventListener` ensures listeners execute only after a transaction commits or rolls back.
* Useful for side-effects like email, logging, syncing.
* Helps maintain consistency and correctness.
* Avoid using plain `@EventListener` in transactional contexts.
* Clean architecture and testable design patterns go hand-in-hand with this approach.

## Good Quote

> "Design systems where your events tell the truth—not a version of it that got rolled back."   
> — Anonymous

That's it for today, will meet in next episode.  
Happy coding :grinning:
