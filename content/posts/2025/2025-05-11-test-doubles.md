---
title: 'Test Doubles'
author: Abhishek
type: post
date: 2025-05-11T20:12:59+05:30
url: "/test-doubles/"
toc: true
draft: false
categories: [ "Testing" ]
tags: [ "Testing", "Junit", "Best Practices", "AssertJ" ]
---

In the world of unit testing, one of the most important goals is to isolate the code being tested from its dependencies.
This ensures that unit tests are fast, reliable, and focused only on testing the logic of the code. One of the key
strategies to achieve this isolation is the use of **test doubles**. Test doubles allow us to replace real dependencies
with simpler, controllable objects during testing.

In this blog post, we will explore the concept of test doubles, discuss the different types, provide practical examples,
and outline best practices for using them effectively in your unit tests. By the end, you’ll be equipped with the
knowledge to apply test doubles in your own testing strategies.

## 1) Problem

In software development, especially when writing unit tests, one common challenge is testing components in isolation.
Often, the code under test interacts with external dependencies such as databases, services, or APIs. These external
dependencies can make testing difficult because:

- They introduce unpredictability (e.g., network failures or delays).
- They complicate test setup and teardown.
- They make tests slower and harder to maintain.

To overcome these challenges, we need a way to isolate the code under test from its dependencies, ensuring that the unit
tests are fast, deterministic, and focused on testing only the logic of the code under test.

## 2) Solution: Test Doubles

Test doubles are a group of objects that stand in for real objects in tests. They allow us to simulate the behavior of
real dependencies in a controlled way. There are several types of test doubles, including:

- **Mocks:** Pre-programmed with expectations and return values. They verify interactions during the test.
- **Stubs:** Return pre-defined responses but do not check interactions.
- **Spies:** Record interactions with the test object, allowing us to verify the method calls after the test.
- **Fakes:** Provide a simplified, functional version of a dependency (e.g., an in-memory database).
- **Dummies:** Objects passed around but never used. They are often placeholders in test scenarios.

### Example 1: Using Mockito for Mocks

Mocks are typically used when we need to verify interactions with a dependency. They allow us to set expectations on
method calls and verify that those expectations are met.

```java
@Test
void should_return_user_when_found() {
    // Arrange
    UserRepository userRepository = mock(UserRepository.class);
    User user = new User("John", "Doe");
    when(userRepository.findById(1)).thenReturn(Optional.of(user));

    // Act
    Optional<User> foundUser = userRepository.findById(1);

    // Assert
    assertThat(foundUser).isPresent();
    assertThat(foundUser.get().getFirstName()).isEqualTo("John");
}
```

In the above example, we mock the UserRepository so we don't need a real database. We define the behavior of the
findById() method using Mockito.when(), which allows us to test the logic of the component that interacts with the
UserRepository.

### Example 2: Using Stubs

Stubs provide fixed responses for methods but do not check interactions. They are useful when you want to control the
data returned from a dependency without verifying how it was used.

```java
@Test
void should_return_discounted_price() {
    // Arrange
    PriceCalculator priceCalculator = new PriceCalculator();
    DiscountService discountService = mock(DiscountService.class);
    when(discountService.getDiscount("SUMMER")).thenReturn(0.2); // Stubbed response

    // Act
    double finalPrice = priceCalculator.calculatePrice(100.0, discountService, "SUMMER");

    // Assert
    assertThat(finalPrice).isEqualTo(80.0); // 100 - 20% discount
}
```

Here, the DiscountService is stubbed to return a fixed discount percentage. This allows us to test the PriceCalculator
logic without actually implementing a real discount calculation.

### Example 3: Using Spies

Spies are like mocks but with a twist—they allow us to spy on real objects. You can track method calls and verify
interactions after the test has run.

```java
@Test
void should_log_price_calculation() {
    // Arrange
    LoggerService loggerService = spy(new LoggerService());
    PriceCalculator priceCalculator = new PriceCalculator(loggerService);

    // Act
    priceCalculator.calculatePrice(100.0, 0.1);

    // Assert
    verify(loggerService).log("Price calculated: 90.0");
}
```

In this example, we spy on the LoggerService to track its method calls. After calling calculatePrice(), we verify that
the log() method was called with the expected message.

### Example 4: Using Fakes

Fakes provide a simplified version of a dependency. A common example is using an in-memory database in tests.

```java
@Test
void should_save_and_retrieve_user() {
    // Arrange
    UserRepository userRepository = new InMemoryUserRepository(); // Fake repository
    User user = new User("John", "Doe");

    // Act
    userRepository.save(user);
    Optional<User> retrievedUser = userRepository.findById(user.getId());

    // Assert
    assertThat(retrievedUser).isPresent();
    assertThat(retrievedUser.get().getFirstName()).isEqualTo("John");
}
```

In this example, we use a fake UserRepository that stores data in memory. This allows us to test the logic without
relying on a real database.

### Example 5: Using Dummies

Dummies are used when you need an object to fulfill a method signature but it isn't used in the actual test. These are
typically placeholders.

```java
@Test
void should_process_order_with_dummy_payment() {
    // Arrange
    PaymentProcessor paymentProcessor = new PaymentProcessor();
    Order order = new Order("Laptop", 1000);
    PaymentGateway dummyPaymentGateway = new PaymentGateway(); // Dummy object

    // Act
    paymentProcessor.processPayment(order, dummyPaymentGateway);

    // Assert
    assertThat(order.getStatus()).isEqualTo("Paid");
}
```

In this example, the dummyPaymentGateway is passed to the processPayment() method but isn't used within the test. It
just fulfills the method parameter requirement.

## 3) Best Practices for Using Test Doubles

While test doubles are powerful tools, they should be used correctly to avoid introducing problems into the tests
themselves. Here are some best practices to follow:

### 1. Use the Right Type of Test Double

Mocks are best when you need to verify interactions, such as ensuring a method was called.

Stubs are useful when you need to return fixed data without verifying interactions.

Spies are helpful when you need to record interactions for later verification but don't want to mock every method.

Fakes are suitable for simpler replacements of real dependencies, like an in-memory database.

Dummies should be used sparingly and only when an object is required but not used in the test.

### 2. Keep Tests Isolated

Test doubles should help isolate the unit under test. Avoid introducing unnecessary complexity or dependencies in the
test setup.

### 3. Avoid Overusing Mocks

While mocks are useful for interaction verification, overusing them can lead to brittle tests. Mocking too many
dependencies can make tests hard to maintain and change, especially when the behavior of the dependencies changes.

### 4. Use Real Objects When Possible

Prefer using real objects when the dependencies are simple and can be easily controlled. Use test doubles only when
interacting with the real dependencies would complicate the test.

### 5. Document Expectations Clearly

When using mocks, always document what interactions you expect and why. This helps others understand the purpose of
the test and reduces confusion.

### 6. Avoid Testing the Framework

Don't mock or stub the framework you're using (e.g., Mockito or JUnit). Focus on testing your business logic, not the
testing framework.

By following these practices, you can effectively use test doubles to improve the quality, speed, and reliability of
your unit tests.

That's it for today, will meet in next episode.

Happy testing :grinning:
