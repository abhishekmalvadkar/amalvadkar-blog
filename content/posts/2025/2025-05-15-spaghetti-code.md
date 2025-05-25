---
title: 'Spaghetti Code'
author: Abhishek
type: post
date: 2025-05-15T11:37:44+05:30
url: "/spaghetti-code/"
toc: true
draft: false
categories: [ "architecture" ]
tags: [ "low-level-design" ]
---

A few years ago, during a production release weekend, we discovered a critical bug in a Spring Boot application. The
logic for a simple feature—sending a birthday email—was spread across multiple classes, utility files, and even embedded
inside a controller. No one could confidently say what triggered the email or why it was failing.

After hours of debugging, someone muttered, “This looks like spaghetti.” Indeed, the code was tangled like
pasta—unstructured, messy, and impossible to trace. That was my first encounter with **Spaghetti Code**.

## Problem – What is Spaghetti Code?

**Spaghetti Code** refers to software with a tangled control structure, usually due to unstructured programming or
improper layering. It’s a sign of poor design and is hard to read, test, or maintain.

### Symptoms of Spaghetti Code:

- Logic spread across multiple unrelated files
- Tight coupling with no clear structure
- Hardcoded business logic in controllers or UI
- Long methods with nested conditionals
- Lack of modularity or abstraction

## Solution – How to Avoid or Refactor It

- Use **layered architecture**: Controller → Service → Repository
- Apply **Separation of Concerns**
- Extract methods and classes for clarity
- Adopt **Domain-Driven Design**
- Write unit and integration tests
- Use clean, self-explanatory names
- Regularly refactor and review code

## Examples in Detailed Way

### Bad Example – Spaghetti Code in Controller

```java

@RestController
@RequestMapping("/users")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/birthday-email")
    public ResponseEntity<String> sendBirthdayEmail(@RequestBody String email) {
        User user = userRepository.findByEmail(email);
        if (user != null) {
            LocalDate birthDate = user.getBirthDate();
            if (birthDate != null && birthDate.equals(LocalDate.now())) {
                String message = "Happy Birthday " + user.getName();
                // simulate sending email
                System.out.println("Sending email to: " + user.getEmail());
                return ResponseEntity.ok(message);
            }
        }
        return ResponseEntity.badRequest().body("Not user birthday or user not found");
    }
}
```

#### Problems:

- Business logic directly in controller
- No separation of concerns
- Hard to reuse or test

---

### Good Example – Cleaned Up Structure

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

    public boolean sendBirthdayEmail(String email) {
        User user = userRepository.findByEmail(email);
        if (user != null && LocalDate.now().equals(user.getBirthDate())) {
            String message = "Happy Birthday " + user.getName();
            emailService.sendEmail(user.getEmail(), message);
            return true;
        }
        return false;
    }
}
```

#### `UserController.java`

```java

@RestController
@RequestMapping("/users")
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping("/birthday-email")
    public ResponseEntity<String> sendBirthdayEmail(@RequestBody String email) {
        boolean success = userService.sendBirthdayEmail(email);
        return success
                ? ResponseEntity.ok("Birthday email sent!")
                : ResponseEntity.badRequest().body("Not user birthday or user not found");
    }
}
```

#### Benefits:

- Clear separation of responsibilities
- Easier to test and maintain
- Logic is modular and reusable

## Best Practices to Avoid Spaghetti Code

- Apply **layered architecture** consistently
- Keep controllers thin, services smart
- Use small, well-named methods
- Group related logic into cohesive classes
- Avoid deep nesting and complex conditionals
- Perform regular code reviews and refactoring

## Final Thoughts

Spaghetti Code doesn’t happen all at once—it creeps in with every rushed deadline, every shortcut, and every “just this
once.” But the cost adds up quickly, making even simple changes risky and time-consuming.

Take time to design your code, separate concerns, and write clean, modular logic. Future-you (and your teammates) will
be grateful.

## Summary

- **Problem**:  
  Spaghetti Code creates tangled logic, making code hard to read, test, and maintain.

- **Solution**:  
  Apply layered architecture and DDD principles to structure code clearly.

- **Example**:  
  Moved business logic from a cluttered controller to dedicated services.

- **Best Practices**:  
  Separate concerns, write clean methods, and refactor regularly.

## Good Quote

> “Clean code always looks like it was written by someone who cares.”  
> — Robert C. Martin

That's it for today, will meet in next episode.  
Happy architecture :grinning: