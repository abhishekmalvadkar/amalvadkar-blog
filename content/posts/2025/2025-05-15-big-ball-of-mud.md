---
title: 'Big Ball of Mud'
author: Abhishek
type: post
date: 2025-05-15T11:12:51+05:30
url: "/big-ball-of-mud/"
toc: true
draft: false
categories: [ "architecture" ]
tags: [ "low-level-design"]
---

A few years ago, I joined a fast-growing startup. Their Spring Boot application was core to the business, but every new
feature we tried to implement turned into a nightmare. There were no clear boundaries. A single class had 2,000+ lines
of code, services talked directly to repositories across modules, and the same logic was duplicated in different corners
of the codebase.

When I asked a senior developer about the structure, he replied, “It just evolved that way... we had to move fast.” What
they had built was not a maintainable system—it was a **Big Ball of Mud**.

## Problem – What is a Big Ball of Mud?

A **Big Ball of Mud** is a software system with no recognizable architecture. It’s a tangled, haphazard structure that
evolved over time, full of code smells, duplicated logic, and tight coupling. It works—but it's hard to understand, hard
to maintain, and even harder to extend.

### Characteristics of a Big Ball of Mud:

- No separation of concerns
- Tight coupling and poor cohesion
- God classes and bloated services
- Repetitive code and quick fixes
- Poorly named or multipurpose classes
- Hard to test and debug

## Solution – How to Avoid or Refactor It

To fix or prevent a Big Ball of Mud, we need to:

- Adopt layered architecture (e.g., Controller → Service → Repository)
- Enforce separation of concerns
- Embrace domain-driven design (DDD)
- Write unit and integration tests
- Use refactoring techniques
- Continuously review code (peer reviews, automated tools)

It’s not about slowing down—it's about building sustainable software.

## Examples in Detailed Way

### Bad Example – Big Ball of Mud in Spring Boot

```java

@RestController
public class OrderController {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private CustomerRepository customerRepository;

    @Autowired
    private EmailService emailService;

    @PostMapping("/order")
    public ResponseEntity<String> placeOrder(@RequestBody OrderRequest orderRequest) {
        Customer customer = customerRepository.findById(orderRequest.getCustomerId()).orElse(null);
        if (customer == null) {
            return ResponseEntity.badRequest().body("Customer not found");
        }

        Order order = new Order();
        order.setCustomer(customer);
        order.setItems(orderRequest.getItems());
        order.setCreatedAt(LocalDateTime.now());

        orderRepository.save(order);

        emailService.sendEmail(customer.getEmail(), "Order placed successfully!");

        return ResponseEntity.ok("Order placed");
    }
}
```

#### Problems:

- Controller does too much: validation, business logic, persistence, and even email.
- No service layer.
- No domain separation.
- Testing this controller is hard.

---

### Good Example – Refactored Clean Code

#### `OrderController.java`

```java

@RestController
@RequestMapping("/orders")
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @PostMapping
    public ResponseEntity<String> placeOrder(@RequestBody OrderRequest request) {
        orderService.placeOrder(request);
        return ResponseEntity.ok("Order placed");
    }
}
```

#### `OrderService.java`

```java

@Service
public class OrderService {

    private final OrderRepository orderRepository;
    private final CustomerRepository customerRepository;
    private final EmailService emailService;

    public OrderService(OrderRepository orderRepository, CustomerRepository customerRepository, EmailService emailService) {
        this.orderRepository = orderRepository;
        this.customerRepository = customerRepository;
        this.emailService = emailService;
    }

    public void placeOrder(OrderRequest request) {
        Customer customer = customerRepository.findById(request.getCustomerId())
                .orElseThrow(() -> new IllegalArgumentException("Customer not found"));

        Order order = new Order(customer, request.getItems());
        orderRepository.save(order);

        emailService.sendEmail(customer.getEmail(), "Order placed successfully!");
    }
}
```

#### Benefits:

- Clear separation of responsibilities
- Testable service layer
- Maintainable code
- Readable flow
- Scalability for future features

## Best Practices to Avoid the Big Ball of Mud

- **Start with simple architecture**: Use the layered architecture and refactor when needed.
- **Enforce clear boundaries**: Keep controllers, services, repositories, and domain models separate.
- **Practice Clean Code principles**: Follow SOLID, DRY, and single responsibility.
- **Use domain-driven design**: Structure the code to reflect real business concepts.
- **Write tests early**: TDD helps design clean, modular, and testable code.
- **Refactor regularly**: Don’t wait for a disaster to clean up your code.
- **Automate static code analysis**: Use tools like SonarQube, Checkstyle, or PMD.

## Final Thoughts

Big Ball of Mud is not just a technical issue—it’s a cultural one. When teams prioritize speed over quality without
discipline, architecture crumbles. Clean code doesn't mean overengineering; it means thinking long-term.

If you find yourself in a mud ball, start cleaning it one test and one refactor at a time. It's never too late to
introduce good practices.

## Summary

**Problem**:  
The codebase becomes unstructured, tightly coupled, and difficult to maintain.

**Solution**:  
Apply layered architecture, write clean code, adopt Domain-Driven Design (DDD), and ensure proper testing.

**Example**:  
Refactored `OrderController` by separating responsibilities into service and repository layers for clarity and testability.

**Best Practices**:  
Follow SOLID principles, maintain separation of concerns, and perform regular code refactoring to avoid architectural decay.


## Good Quote

> "The only way to go fast, is to go well."  
> — Robert C. Martin (Uncle Bob)

That's it for today, will meet in next episode.

Happy architecture :grinning:

