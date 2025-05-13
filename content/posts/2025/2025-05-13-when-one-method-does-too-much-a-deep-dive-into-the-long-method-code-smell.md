---
title: 'When One Method Does Too Much: A Deep Dive Into the Long Method Code Smell'
author: Abhishek
type: post
date: 2025-05-13T11:21:04+05:30
url: "/when-one-method-does-too-much-a-deep-dive-into-the-long-method-code-smell/"
toc: true
draft: false
categories: [ "Refactoring" ]
tags: [ "Code Smells" ]
---

As developers, we often start with simple logic and keep adding conditions, validations, and feature branches. What
begins as a few lines in a method can quickly balloon into a hundreds-of-lines monster. You’ve probably thought: “It’s
just one method — I’ll come back and clean it later.” But later never comes. Welcome to the world of **Long Method** — a
common code smell that creeps into even the best codebases.

## Development story

You’re building a Spring Boot REST API for handling customer orders. It’s going well, but as new features like
discounting, tax handling, reward points, and order logging get added, your once-tidy `placeOrder()` method now spans
over 100 lines.

You’re under a deadline, tests are passing, and everything “works,” but when a bug occurs or a new feature is
requested — you dread opening that method.

## Problem

A **Long Method** does too many things, often violating the **Single Responsibility Principle**. Problems include:

- **Poor readability** – developers must scroll and parse too much logic
- **Low testability** – hard to unit test different logical branches
- **Duplication** – similar code blocks repeated across the method
- **Tightly coupled logic** – makes refactoring risky and error-prone

Long methods grow silently and discourage contribution or changes.

## Solution

To resolve a long method:

- **Break down the logic** into smaller, meaningful private methods
- Group logic based on **cohesive tasks** (e.g., validation, transformation, persistence)
- Use **early returns** to reduce nesting
- Extract domain-specific logic to dedicated **services** or **helpers**
- Follow **Clean Code**’s guidance: *“Shorter is better. A method should hardly ever be 20 lines long.”*

## Examples

### Before Refactoring (Long Method Smell)

```java
public OrderResponse placeOrder(OrderRequest request) {
    if (request == null || request.getItems().isEmpty()) {
        throw new IllegalArgumentException("Order cannot be empty");
    }

    BigDecimal total = BigDecimal.ZERO;
    for (OrderItem item : request.getItems()) {
        total = total.add(item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
    }

    if (request.getCouponCode() != null) {
        total = applyDiscount(total, request.getCouponCode());
    }

    BigDecimal tax = total.multiply(new BigDecimal("0.18"));
    total = total.add(tax);

    RewardPoints points = rewardService.calculatePoints(total);
    userService.addPoints(request.getUserId(), points);

    Order order = new Order();
    order.setUserId(request.getUserId());
    order.setTotal(total);
    order.setItems(request.getItems());
    order.setCreatedAt(LocalDateTime.now());
    orderRepository.save(order);

    notificationService.sendOrderConfirmation(order);
    auditService.log("Order placed: " + order.getId());

    return new OrderResponse(order.getId(), total);
}
```

This method:

- Validates input
- Calculates total, tax, and rewards
- Persists data
- Sends notifications
- Logs audit

**Too much going on in a single method.**

### After Refactoring (Clean & Modular)

```java
public OrderResponse placeOrder(OrderRequest request) {
    validateRequest(request);

    BigDecimal total = calculateTotal(request);
    applyRewards(request.getUserId(), total);

    Order order = buildOrder(request, total);
    orderRepository.save(order);

    postOrderActions(order);

    return new OrderResponse(order.getId(), total);
}

private void validateRequest(OrderRequest request) {
    if (request == null || request.getItems().isEmpty()) {
        throw new IllegalArgumentException("Order cannot be empty");
    }
}

private BigDecimal calculateTotal(OrderRequest request) {
    BigDecimal total = request.getItems().stream()
            .map(item -> item.getPrice().multiply(BigDecimal.valueOf(item.getQuantity())))
            .reduce(BigDecimal.ZERO, BigDecimal::add);

    if (request.getCouponCode() != null) {
        total = applyDiscount(total, request.getCouponCode());
    }

    BigDecimal tax = total.multiply(new BigDecimal("0.18"));
    return total.add(tax);
}

private void applyRewards(Long userId, BigDecimal total) {
    RewardPoints points = rewardService.calculatePoints(total);
    userService.addPoints(userId, points);
}

private Order buildOrder(OrderRequest request, BigDecimal total) {
    Order order = new Order();
    order.setUserId(request.getUserId());
    order.setTotal(total);
    order.setItems(request.getItems());
    order.setCreatedAt(LocalDateTime.now());
    return order;
}

private void postOrderActions(Order order) {
    notificationService.sendOrderConfirmation(order);
    auditService.log("Order placed: " + order.getId());
}
```

Each helper method now has a clear name and purpose. Much easier to test, debug, and evolve.

## Summary

The **Long Method** smell hurts readability and maintainability. As logic grows, break it into bite-sized,
intention-revealing methods. Let methods tell a story — clearly and simply.

## Final Thoughts

Refactoring long methods is one of the most impactful ways to improve code health. Start small. Extract just one section
into a private method and give it a good name. You’ll instantly make your code more readable and enjoyable.

## Good Quote

> “The first rule of functions is that they should be small. The second rule is that they should be smaller than
> that.”  
> — *Robert C. Martin (Uncle Bob)*

That's it for today, will meet in next episode.

Happy refactoring :grinning: