---
title: 'Spring Boot Programmatic Transaction Handling'
author: Abhishek
type: post
date: 2025-05-22T12:07:55+05:30
url: "/spring-boot-programmatic-transaction-handling/"
toc: true
draft: false
categories: [ "spring boot" ]
tags: [ "spring-transaction" ]
---

A few months back, I was working on a critical payroll processing module for an HRMS application. One evening, I got a
frantic call from QA: "Some users got paid twice, and some not at all!" We had been relying entirely on declarative
`@Transactional` annotations, but certain business logic in the service layer included conditional database operations,
external API calls, and dynamic transaction boundaries. Declarative transaction management just couldn’t handle this
complexity. That’s when I discovered the real power of **programmatic transaction handling in Spring Boot**. It helped
us solve the problem precisely, with full control over transaction boundaries.

## Problem

While declarative transaction management using `@Transactional` is simple and widely used, it falls short in the
following scenarios:

* **Dynamic transaction boundaries**: When you need to control where a transaction starts and ends at runtime.
* **Nested transactions or partial rollbacks**: Sometimes you need to commit part of the data while rolling back the
  rest.
* **Multiple transactional contexts**: Handling different databases or isolated transaction blocks in one logical flow.
* **Conditional rollbacks**: Based on external API calls or complex business rules.

These cases require **fine-grained control**, and that's where **programmatic transaction handling** comes to the
rescue.

## Solution

Spring Boot provides multiple ways to handle transactions programmatically:

* Using `TransactionTemplate`
* Using `PlatformTransactionManager` directly
* Using `TransactionalOperator` in reactive programming

These allow developers to define transactions in Java code, start and commit them explicitly, and handle rollbacks based
on logic and exceptions.

## Multiple Examples with Detailed Explanation

### 1. Using `TransactionTemplate`

```java

@Service
public class PayrollService {

    private final TransactionTemplate transactionTemplate;
    private final EmployeeRepository employeeRepository;

    public PayrollService(PlatformTransactionManager transactionManager,
                          EmployeeRepository employeeRepository) {
        this.transactionTemplate = new TransactionTemplate(transactionManager);
        this.employeeRepository = employeeRepository;
    }

    public void processPayroll() {
        transactionTemplate.executeWithoutResult(status -> {
            try {
                // Business logic
                employeeRepository.updateSalary(1L, 5000);
                externalApiCall(); // could fail
                employeeRepository.markProcessed(1L);
            } catch (Exception ex) {
                status.setRollbackOnly();
                log.error("Error during payroll processing", ex);
            }
        });
    }
}
```

### Explanation

* `TransactionTemplate` executes the transaction block.
* `setRollbackOnly()` marks the transaction for rollback manually if any exception occurs.
* It's ideal for cases where you need to mix DB and non-DB logic.

---

### 2. Using `PlatformTransactionManager` Directly

```java

@Service
public class ReportService {

    private final PlatformTransactionManager transactionManager;
    private final ReportRepository reportRepository;

    public ReportService(PlatformTransactionManager transactionManager, ReportRepository reportRepository) {
        this.transactionManager = transactionManager;
        this.reportRepository = reportRepository;
    }

    public void generateReports() {
        DefaultTransactionDefinition def = new DefaultTransactionDefinition();
        TransactionStatus status = transactionManager.getTransaction(def);

        try {
            reportRepository.saveReport("Q1 Report");
            // Assume this could throw exception
            riskyBusinessLogic();
            transactionManager.commit(status);
        } catch (Exception ex) {
            transactionManager.rollback(status);
            log.error("Report generation failed", ex);
        }
    }
}
```

### Explanation

* Full control of transaction lifecycle.
* Allows granular try-catch blocks around critical sections.
* Suitable for legacy-style control needs.

---

### 3. Handling Partial Rollback

```java

@Service
public class OrderService {

    private final PlatformTransactionManager transactionManager;
    private final OrderRepository orderRepository;
    private final AuditRepository auditRepository;

    public OrderService(PlatformTransactionManager transactionManager,
                        OrderRepository orderRepository,
                        AuditRepository auditRepository) {
        this.transactionManager = transactionManager;
        this.orderRepository = orderRepository;
        this.auditRepository = auditRepository;
    }

    public void processOrder() {
        TransactionStatus orderStatus = transactionManager.getTransaction(new DefaultTransactionDefinition());

        try {
            orderRepository.createOrder();
            transactionManager.commit(orderStatus);
        } catch (Exception e) {
            transactionManager.rollback(orderStatus);
        }

        TransactionStatus auditStatus = transactionManager.getTransaction(new DefaultTransactionDefinition());

        try {
            auditRepository.logAction("Order processed");
            transactionManager.commit(auditStatus);
        } catch (Exception e) {
            transactionManager.rollback(auditStatus);
        }
    }
}
```

### Explanation

* Two separate transactions: one for core logic, another for logging.
* Ensures that audit failure does not impact core business logic.

### 4. Reactive Example with `TransactionalOperator`

```java

@Service
public class ReactiveUserService {

    private final TransactionalOperator transactionalOperator;
    private final UserRepository userRepository;

    public ReactiveUserService(TransactionalOperator transactionalOperator, UserRepository userRepository) {
        this.transactionalOperator = transactionalOperator;
        this.userRepository = userRepository;
    }

    public Mono<Void> createUser(User user) {
        return transactionalOperator.execute(tx ->
                userRepository.save(user)
                        .then(Mono.fromRunnable(() -> System.out.println("User created")))
        ).then();
    }
}
```

## Best Practices

* **Encapsulate transaction logic**: Don’t spread transaction logic across multiple methods.
* **Keep transactions short**: Minimize the code inside a transaction to avoid locks.
* **Handle exceptions properly**: Always wrap risky logic in try-catch blocks and set rollback manually if needed.
* **Log transaction failures**: It helps in debugging production issues.
* **Test both success and rollback scenarios**.

## Anti Patterns

* **Mixing transaction logic with presentation layer**
* **Opening transactions too early and closing too late**
* **Not setting rollback in catch block**
* **Using `@Transactional` along with manual transaction management—can lead to confusion and bugs**
* **Ignoring transaction isolation levels**

## Final Thoughts

Programmatic transaction management gives you the surgical precision needed for advanced business flows. While
declarative transactions are great for most use cases, every architect or senior developer should be equipped to handle
transactions programmatically when complexity demands it.

## Summary

* Spring Boot supports both declarative and programmatic transactions.
* Use programmatic transactions when you need fine-grained control.
* `TransactionTemplate` and `PlatformTransactionManager` are your go-to tools.
* Keep transactions focused, short, and well-handled.
* Avoid anti-patterns to maintain clean, consistent behavior.

## Good Quote

> "Simplicity is about subtracting the obvious and adding the meaningful."   
> — John Maeda



That's it for today, will meet in next episode.  
Happy coding :grinning:
