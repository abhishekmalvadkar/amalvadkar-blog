---
title: 'Spring Custom and Built in Events: A Complete Guide'
author: Abhishek
type: post
date: 2025-05-20T12:02:07+05:30
url: "/spring-custom-and-built-in-events-a-complete-guide/"
toc: true
draft: false
categories: [ "spring boot" ]
tags: [ "spring-events" ]
---

A few years ago, I was working on a large e-commerce platform. One day, our team was asked to implement a feature that
would send a welcome email to users *after* they registered. Simple enough, right? We added the email logic directly
inside the registration service. Initially, it worked fine. But soon, marketing wanted us to send coupons as well. Then
logging was added. Then analytics tracking. And then... the registration service grew into a bloated mess.

The real problem was tight coupling. Every new requirement was dragging the registration logic further away from its
single responsibility. That's when we discovered the power of **Spring events** — a simple but powerful way to implement
decoupled, asynchronous communication within the application.

## Problem

In most applications, especially monoliths, different components often need to respond to the same action. Consider
these scenarios:

* After a user signs up, we need to send a welcome email, notify the marketing team, and log the event.
* After a payment is processed, inventory should be updated, and the warehouse should be notified.

If all of these actions are handled in a single service method, it becomes tightly coupled, hard to test, and prone to
change ripple effects.

### Challenges:

* **Tight coupling** of responsibilities
* **Scattered logic** in the same class
* **Code that’s hard to maintain or scale**
* **Difficult to add new listeners without modifying core logic**

## Solution: Spring Events to the Rescue

Spring Framework provides an elegant **event-driven** programming model. It allows you to publish and listen to events
in a decoupled fashion.

There are two kinds of events in Spring:

1. **Built-in Events** - Provided by the Spring framework.
2. **Custom Events** - Created by developers for domain-specific actions.

Spring's event system is synchronous by default, but it can be made asynchronous using `@Async`.

## Examples

### 1. Built-in Events

Spring publishes several events automatically during the lifecycle of the application:

#### a. `ContextRefreshedEvent`

```java

@Component
public class StartupListener {
    @EventListener
    public void handleContextRefresh(ContextRefreshedEvent event) {
        System.out.println("Application context refreshed!");
    }
}
```

**Use Case**: Useful for initializing beans or services after the application is fully started.

#### b. `ContextClosedEvent`

```java
@Component
public class ShutdownListener {
    @EventListener
    public void onShutdown(ContextClosedEvent event) {
        System.out.println("Application is shutting down...");
    }
}
```

**Use Case**: Clean up resources, close connections, flush logs.

#### c. `ApplicationReadyEvent`

```java

@Component
public class ReadyListener {
    @EventListener
    public void onApplicationReady(ApplicationReadyEvent event) {
        System.out.println("App is ready to accept requests!");
    }
}
```

**Use Case**: Notify external systems, run background jobs after startup.

### 2. Custom Events

#### a. Define the Event

```java
public class UserRegisteredEvent extends ApplicationEvent {
    private final String email;

    public UserRegisteredEvent(Object source, String email) {
        super(source);
        this.email = email;
    }

    public String getEmail() {
        return email;
    }
}
```

#### b. Publish the Event

```java
@Service
public class UserService {

    private final ApplicationEventPublisher publisher;

    public UserService(ApplicationEventPublisher publisher) {
        this.publisher = publisher;
    }

    public void registerUser(String email) {
        // registration logic
        System.out.println("User registered: " + email);

        publisher.publishEvent(new UserRegisteredEvent(this, email));
    }
}
```

#### c. Listen to the Event

```java

@Component
public class WelcomeEmailListener {

    @EventListener
    public void sendWelcomeEmail(UserRegisteredEvent event) {
        System.out.println("Sending welcome email to " + event.getEmail());
    }
}
```

#### d. Multiple Listeners

```java

@Component
public class CouponService {

    @EventListener
    public void sendCoupon(UserRegisteredEvent event) {
        System.out.println("Sending coupon to " + event.getEmail());
    }
}
```

### Making It Asynchronous

To avoid blocking the main thread:

```java
@EnableAsync
@Configuration
public class AsyncConfig {}

@Component
public class AsyncListener {

    @Async
    @EventListener
    public void handle(UserRegisteredEvent event) {
        System.out.println("Async processing for " + event.getEmail());
    }
}
```

## Best Practices

* **Keep listeners lightweight** – Avoid heavy operations in synchronous listeners.
* **Use events for decoupling**, not for core workflows that must complete reliably.
* **Name events clearly** – Use domain-specific naming for readability.
* **Document event flows** – Developers should know what triggers what.
* **Asynchronous where needed** – Prevent blocking operations.
* **Avoid side effects** in event listeners that alter system state.

## Anti Patterns

* **Overusing events** for every action can make the system hard to trace.
* **Using events to implement core business logic** that must complete successfully (e.g., payment processing).
* **Tightly coupling listeners** – one listener calling another synchronously.
* **Ignoring exceptions** – unhandled exceptions in listeners can fail silently.

## Final Thoughts

Spring's event model is a powerful tool to create a clean, loosely-coupled architecture. But, like all tools, it must be
used wisely. Events are great for **notifications**, **side-effects**, and **background tasks**, but not for
business-critical chains where sequencing or error-handling is mandatory.

In our e-commerce system, the moment we migrated side-effect logic into events, we regained clarity, testability, and
confidence in our codebase. Events gave us the separation of concerns we desperately needed.

## Summary

* Spring supports both **built-in** and **custom** events.
* Events help in **decoupling** components.
* Use **@EventListener** to handle events.
* Leverage **@Async** for non-blocking listeners.
* Avoid using events as a replacement for **core business flows**.

## A Good Quote

> "Programs must be written for people to read, and only incidentally for machines to execute." — Harold Abelson

Use Spring events to make your code readable, testable, and maintainable — not magical.

That's it for today, will meet in next episode.  
Happy coding :grinning:

