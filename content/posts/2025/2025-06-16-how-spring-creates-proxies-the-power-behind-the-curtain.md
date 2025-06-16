---
title: 'How Spring Creates Proxies the Power Behind the Curtain'
author: Abhishek
type: post
date: 2025-06-16T11:57:13+05:30
url: "/how-spring-creates-proxies-the-power-behind-the-curtain/"
toc: true
draft: false
categories: [ "SPRING" ]
tags:
  - spring-magic
---

A few years ago, while working on a healthcare management system, I encountered a strange bug: even though I had marked
a method with @Transactional, the database changes weren't rolling back when an exception occurred. I double-checked the
logic — everything looked right. But then I realized I was calling another @Transactional method from inside the same
class. That’s when I discovered the root cause: Spring was using a proxy to handle transactions, and internal calls
weren’t going through it. That bug taught me one of the most powerful and underrated mechanisms in Spring — how it uses
proxies under the hood to magically enable features like transactions, caching, logging, and more. This blog is the
story behind that magic.

During one of my early projects using Spring Framework, I created a simple service:

```java
@Service
public class NotificationService {
    public void sendEmail(String to) {
        System.out.println("Sending email to " + to);
    }
}
```

Then I added a method-level annotation:

```java

@LogExecutionTime
public void sendEmail(String to) { ...}
```

To support this, I created an aspect using Spring AOP:

```java

@Aspect
@Component
public class LoggingAspect {

    @Around("@annotation(LogExecutionTime)")
    public Object logExecution(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();
        Object proceed = joinPoint.proceed();
        long end = System.currentTimeMillis();
        System.out.println(joinPoint.getSignature() + " took " + (end - start) + "ms");
        return proceed;
    }
}
```

After enabling AOP via `@EnableAspectJAutoProxy`, I expected the magic to happen. And it did. The `sendEmail()` method
got wrapped automatically and printed execution time.

But the real magic? I never called the aspect explicitly. I never wrapped the service manually.

**So, how did Spring know to wrap the method with logging?**

That’s when I learned about one of Spring's most powerful tools: **proxies**.

---

## What Is a Proxy?

A proxy is a wrapper around an object. Think of it like a middleman that intercepts calls to your object and can perform
additional logic before or after forwarding the call.

In Spring, proxies are commonly used for:

* Aspect-Oriented Programming (AOP)
* Transaction management
* Lazy loading
* Security
* Caching

Spring creates these proxies **dynamically at runtime** — either using Java’s reflection-based **JDK dynamic proxies**
or bytecode-generation-based **CGLIB proxies**.

---

## When Does Spring Create a Proxy?

Spring creates a proxy when:

* A bean requires **cross-cutting concerns** (e.g., logging, transactions)
* A bean has an aspect targeting it
* A method is annotated with things like `@Transactional`, `@Async`, etc.
* The bean needs to be lazily initialized or scoped (e.g., request scope in web apps)

These proxies are created **automatically by the Spring container** during bean initialization.

---

## Types of Proxies in Spring

### 1. JDK Dynamic Proxy

* **Used when the bean implements an interface**
* Relies on `java.lang.reflect.Proxy`
* Proxy object implements the same interfaces as the target bean

**Example:**

```java
public interface MyService {
    void doSomething();
}

@Service
public class MyServiceImpl implements MyService {
    public void doSomething() {
        ...
    }
}
```

Here, Spring uses **JDK dynamic proxy** because it can proxy based on the `MyService` interface.

---

### 2. CGLIB Proxy

* **Used when the bean does not implement any interface**
* Uses **CGLIB (Code Generation Library)** to subclass the target bean
* Spring creates a new class that extends your class and overrides the methods to insert proxy logic

**Example:**

```java

@Service
public class MyConcreteService {
    public void process() {
        ...
    }
}
```

Spring sees that `MyConcreteService` has no interfaces, so it uses **CGLIB proxying**.

**Important:** CGLIB can't proxy `final` classes or `final` methods.

---

## The Lifecycle: How Proxies Are Created in Spring

Let’s walk through what Spring does internally to create a proxy.

### 1. Bean Scanning and Post Processors

When Spring initializes your application context, it:

* Scans all the beans
* Applies `BeanPostProcessors` for customization

One such processor is `AnnotationAwareAspectJAutoProxyCreator`, which:

* Detects whether the bean should be proxied
* Checks for annotations like `@Aspect`, `@Transactional`, `@Async`
* Creates a proxy **before the bean is handed over to you**

### 2. Proxy Creation via ProxyFactory

Spring internally uses a `ProxyFactory` to create the proxy object.

```java
ProxyFactory proxyFactory = new ProxyFactory();
proxyFactory.setTarget(targetBean);
proxyFactory.addAdvice(advice);

Object proxy = proxyFactory.getProxy();
```

Based on whether the bean has interfaces or not, Spring decides:

* `JdkDynamicAopProxy` (for interface-based beans)
* `CglibAopProxy` (for class-based beans)

---

## Real Example: Understanding with @Transactional

Let’s say you have this:

```java

@Service
public class PaymentService {

    @Transactional
    public void processPayment(String userId) {
        // deduct amount, update balance, log history
    }
}
```

Behind the scenes:

1. Spring detects the `@Transactional` annotation.
2. It registers a transaction interceptor.
3. It creates a proxy of `PaymentService` and wraps `processPayment()` with the transaction interceptor.
4. When you call `paymentService.processPayment()`, you're actually calling a proxy method that:

    * Opens a transaction
    * Calls the real method
    * Commits or rolls back the transaction
    * Returns the result

---

## Important Proxy Behavior: Know These Caveats

### 1. Self Invocation Doesn’t Work

If you call another method within the same class that is also annotated with `@Transactional` or `@Async`, the proxy
won't intercept it.

```java

@Service
public class MyService {

    @Transactional
    public void methodA() {
        methodB(); // Won’t run in a new transaction
    }

    @Transactional
    public void methodB() {
        ...
    }
}
```

✅ Use an external call (from another bean) to allow the proxy to work.
✅ Or restructure your logic.

---

### 2. Final Classes and Methods Won’t Be Proxied via CGLIB

Spring can’t subclass a `final` class or override a `final` method. So you’ll get a runtime error or silent failure.

```java
final class MyService { ...
} // ❌ Can't be proxied
```

---

## Debugging and Verification Tips

* Use `AopProxyUtils.ultimateTargetClass(bean)` to see the real class behind a proxy.
* Log the class type:

  ```java
  System.out.println(myBean.getClass()); // Will show proxy class
  ```
* Look for patterns like:

    * `com.sun.proxy.$Proxy...` → JDK proxy
    * `MyService$$EnhancerBySpringCGLIB...` → CGLIB proxy

---

## Can You Manually Create Proxies?

Yes! Spring provides APIs if you want fine-grained control.

```java
ProxyFactory factory = new ProxyFactory(new MyServiceImpl());
factory.addAdvice(new MyMethodInterceptor());
MyService proxy = (MyService) factory.getProxy();
```

Useful when:

* Writing custom AOP infrastructure
* Testing proxies
* Learning Spring internals

## Final Thoughts

Proxies are Spring’s invisible workforce.

They allow cross-cutting logic like transactions, security, and caching to be applied in a **non-invasive way**, without
polluting your business logic.

As a Java Spring Boot developer, understanding **how Spring creates proxies**, **when it creates them**, and **what
limitations they have** gives you superpowers:

* You’ll debug better
* Avoid proxy pitfalls
* Write cleaner, testable code

So the next time something “just works” in Spring, peek behind the curtain. There’s probably a proxy making it happen.

**Keep coding, and may the proxy be with you.** 👨‍💻✨
