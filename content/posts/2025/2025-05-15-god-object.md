---
title: 'God Object'
author: Abhishek
type: post
date: 2025-05-15T11:28:56+05:30
url: "/god-object/"
toc: true
draft: false
categories: [ "architecture" , "system design" ]
tags: [ "architecture" , "low level design" ]
---

A few months ago, I was asked to debug a production issue in a legacy Spring Boot system. I opened the codebase and
found a single class named `ApplicationManager` with over 3,000 lines of code. This class was doing **everything**
—managing database connections, sending emails, calculating business rules, formatting reports, and even responding to
web requests.

It felt like the whole application had only one brain—this **God Object**. Any change, no matter how small, risked
breaking five other things. I realized I wasn’t working with a modular system—I was working with a deity.

## Problem – What is a God Object?

A **God Object** (also called God Class) is an object that knows too much or does too much. It centralizes the
intelligence of a system into one massive class, violating the principles of object-oriented design.

### Symptoms of a God Object:

- Very large classes (thousands of lines)
- Too many responsibilities
- Manipulates many unrelated objects
- Hard to test in isolation
- Breaks Single Responsibility and Encapsulation
- Any change has unpredictable side effects

## Solution – How to Avoid or Refactor It

- Break responsibilities into smaller, focused classes
- Follow the **Single Responsibility Principle (SRP)**
- Apply **Separation of Concerns**
- Use meaningful domain-driven objects
- Apply SOLID principles
- Write unit tests that encourage low coupling

## 4) Examples in Detailed Way

### Bad Example – God Object in Spring Boot

```java

@Component
public class ApplicationManager {

    @Autowired
    private UserRepository userRepository;
    @Autowired
    private EmailService emailService;
    @Autowired
    private ReportService reportService;

    public void registerUser(UserDto userDto) {
        // Validate user
        // Save user
        // Send email
        // Generate report
    }

    public void deleteUser(Long id) {
        // Delete logic
        // Notification logic
    }

    public void generateMonthlyReport() {
        // Report logic
    }

    public void cleanUpOldData() {
        // Archiving logic
    }

    // ... Many unrelated methods
}
```

#### Problems:

- This class handles user logic, report generation, cleanup, and more.
- It's tightly coupled to many services.
- It is impossible to reuse or test parts of it independently.

---

### Good Example – Refactored Clean Code

Break the god object into well-defined services.

#### `UserService.java`

```java

@Service
public class UserService {

    private final UserRepository userRepository;
    private final EmailService emailService;

    public UserService(UserRepository userRepository, EmailService emailService) {
        this.userRepository = userRepository;
        this.emailService = emailService;
    }

    public void registerUser(UserDto dto) {
        // Validate and save user
        userRepository.save(convertToEntity(dto));
        emailService.sendWelcomeEmail(dto.getEmail());
    }

    private User convertToEntity(UserDto dto) {
        return new User(dto.getName(), dto.getEmail());
    }
}
```

#### `ReportService.java`

```java

@Service
public class ReportService {

    public void generateMonthlyReport() {
        // Logic for monthly report
    }
}
```

#### Benefits:

- Each class has a single responsibility.
- Easier to test, maintain, and extend.
- Encourages separation of concerns.

## Best Practices to Avoid the God Object

- **Apply SRP**: Every class should have only one reason to change.
- **Think in domains**: Group logic by business responsibility.
- **Use descriptive names**: Avoid vague names like `Manager`, `Helper`, or `Util` for complex classes.
- **Keep class size small**: If it’s growing too fast, split it.
- **Write modular tests**: Testing will naturally guide your class design.
- **Review code regularly**: Use reviews to identify God Objects early.

## Final Thoughts

The God Object might feel productive at first—it centralizes logic and keeps things “in one place.” But over time, it
slows down development, spreads bugs, and paralyzes the system. In a microservices world, we favor composability and
independence—not divine complexity.

Break your gods into humble, focused services—and your team will thank you.

## Summary

- **Problem**:  
  God Objects take on too many responsibilities, leading to fragile, untestable code.

- **Solution**:  
  Split responsibilities into dedicated, focused services using SOLID principles.

- **Example**:  
  Refactored a bloated `ApplicationManager` class into separate service layers for users and reports.

- **Best Practices**:  
  Apply SRP, group by domain, keep class size small, and review code proactively.

## Good Quote

> “A class should have only one reason to change.”  
> — Robert C. Martin

That's it for today, will meet in next episode.  
Happy architecture :grinning: