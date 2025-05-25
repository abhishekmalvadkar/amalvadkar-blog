---
title: 'Rich Object vs Anemic Object in Domain Driven Design'
author: Abhishek
type: post
date: 2025-05-22T14:48:29+05:30
url: "/rich-object-vs-anemic-object-in-domain-driven-design/"
toc: true
draft: false
categories: [ "domain-driven-design" ]
---

It all started when I joined a fintech startup as a senior developer. The team was under pressure to ship a loan
management module quickly. I inherited a codebase that looked fine at first glance, but as I dived in, I noticed
something odd. The domain objects like `Loan`, `Customer`, and `Repayment` had no behavior. They were just data
holders — a bunch of getters and setters. All business logic was scattered in service classes. Modifying a simple rule
like “early repayment incurs a 2% penalty” required changes in 3 different services. It was fragile, error-prone, and
utterly confusing.

This was my first brush with the concept of **anemic domain models** and why **rich domain models** matter in
Domain-Driven Design (DDD).

## The Problem: Anemic Domain Models

An **anemic domain model** is a common anti-pattern in which domain objects contain only data (fields and simple
getters/setters) and no behavior. All business logic resides in service classes. While this might look clean and
organized, it defeats the purpose of object-oriented programming.

### Symptoms of Anemic Models:

* Domain objects resemble DTOs.
* Business rules are scattered in service layers.
* Difficult to maintain and extend.
* Lacks encapsulation.

### Example:

```java
public class Loan {
    private BigDecimal amount;
    private BigDecimal interestRate;
    private LocalDate startDate;
    private LocalDate endDate;

    // Getters and setters only
}

public class LoanService {
    public BigDecimal calculateTotalPayableAmount(Loan loan) {
        // logic to calculate total
    }

    public void applyEarlyRepaymentPenalty(Loan loan, BigDecimal earlyPayment) {
        // logic to apply penalty
    }
}
```

All domain logic lives in `LoanService`, not in `Loan`. If we’re not careful, our codebase becomes a procedural mess
wearing an object-oriented disguise.

## The Solution: Rich Domain Models

In contrast, a **rich domain model** embeds both data and behavior within the domain objects. It adheres to DDD
principles by ensuring the domain model reflects real-world behavior.

### Characteristics:

* Objects encapsulate both data and logic.
* High cohesion and strong encapsulation.
* Behaviorally expressive.

### Benefits:

* Easier to understand and reason about.
* Business rules live closer to the data they govern.
* Promotes code reuse and readability.

### Refactored Example:

```java
public class Loan {
    private BigDecimal amount;
    private BigDecimal interestRate;
    private LocalDate startDate;
    private LocalDate endDate;

    public BigDecimal calculateTotalPayableAmount() {
        long days = ChronoUnit.DAYS.between(startDate, endDate);
        BigDecimal interest = amount.multiply(interestRate)
                .multiply(BigDecimal.valueOf(days))
                .divide(BigDecimal.valueOf(365), RoundingMode.HALF_UP);
        return amount.add(interest);
    }

    public BigDecimal applyEarlyRepaymentPenalty(BigDecimal earlyPayment) {
        BigDecimal penalty = earlyPayment.multiply(BigDecimal.valueOf(0.02));
        return earlyPayment.subtract(penalty);
    }
}
```

Now, `Loan` knows how to calculate its own total amount and handle penalties — just like in the real world. Services
coordinate domain objects, not dictate their logic.

## Multiple Examples with Explanation

### Example 1: E-Commerce - Order

**Anemic Version**

```java
public class Order {
    private List<OrderItem> items;
    private String status;
    // Getters and setters
}

public class OrderService {
    public void completeOrder(Order order) {
        // logic to complete order
    }

    public BigDecimal calculateTotal(Order order) {
        // logic to calculate total
    }
}
```

**Rich Version**

```java
public class Order {
    private List<OrderItem> items = new ArrayList<>();
    private String status = "PENDING";

    public void completeOrder() {
        this.status = "COMPLETED";
    }

    public BigDecimal calculateTotal() {
        return items.stream()
                .map(OrderItem::getTotalPrice)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
```

### Example 2: HR System - Employee Leave

**Anemic Version**

```java
public class LeaveRequest {
    private LocalDate startDate;
    private LocalDate endDate;
    private String type;
    // Getters and setters
}

public class LeaveService {
    public long calculateLeaveDays(LeaveRequest leaveRequest) {
        // business logic here
    }
}
```

**Rich Version**

```java
public class LeaveRequest {
    private LocalDate startDate;
    private LocalDate endDate;
    private String type;

    public long getLeaveDays() {
        return ChronoUnit.DAYS.between(startDate, endDate) + 1;
    }
}
```

## Best Practices

* **Encapsulate business rules in domain objects.**
* **Favor behavior-rich entities over dumb data holders.**
* **Use services only for orchestration and cross-cutting concerns.**
* **Model real-world behavior accurately.**
* **Write unit tests for domain behavior inside domain classes.**

## Anti-Patterns

* **God Services:** Massive service classes that know too much.
* **Data-Driven Design:** Domain modeled around the database instead of business behavior.
* **Getter/Setter Obsession:** Classes with only getters/setters and no behavior.
* **Behavioral Leakage:** Business rules implemented in multiple places inconsistently.

## Final Thoughts

Anemic domain models may feel simple at the start, but they are costly in the long run. As your business logic grows,
the mess compounds. Rich domain models, while requiring more thoughtful design upfront, scale better and communicate
intent clearly. They align your codebase with your business — and that’s what DDD is all about.

## Summary

* Anemic objects hold data but no logic — a common anti-pattern.
* Rich objects encapsulate both data and behavior — they are core to DDD.
* Refactor domain logic into your domain entities to make code maintainable and expressive.
* Avoid treating your domain objects as mere DTOs.
* Use services to coordinate, not dictate.

## Good Quote

> "Tell, don't ask. Let your objects do the work, not just hold the data."   
> — Object-Oriented Wisdom



That's it for today, will meet in next episode.  
Happy coding :grinning:
