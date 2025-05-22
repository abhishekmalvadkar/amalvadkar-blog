---
title: 'Null Pointer Exception Message Improvement in Jdk 14'
author: Abhishek
type: post
date: 2025-05-22T13:59:12+05:30
url: "/null-pointer-exception-message-improvement-in-new-jdk-versions/"
toc: true
draft: false
categories: [ "java" ]
tags: [ "java-14-features" ]
---

It was a typical Thursday morning. I had just brewed my coffee and opened up my IDE to start working on a bug reported
by QA. "NullPointerException on clicking the user profile tab," the ticket read. Easy one, I thought. But once I looked
at the stack trace, I was greeted with the usual cryptic message:

```shell
Exception in thread "main" java.lang.NullPointerException
	at com.example.UserService.getUserProfile(UserService.java:42)
```

Which object was null? The line had a method call chain with at least three objects. I had to debug and inspect each one
to find the culprit. That’s when I remembered something from the JDK 14 release notes—**improved NullPointerException
messages**. I upgraded my local JDK, ran the code again, and voilà! The error message now clearly pointed to the null
variable.

This experience was eye-opening. Let's explore how this improvement solves a common and frustrating problem.

## Problem

Prior to JDK 14, a `NullPointerException` (NPE) provided limited information:

```java
String name = user.getAddress().getCity().getName();
```

If one of the objects in this call chain was null, you'd get:

```shell
Exception in thread "main" java.lang.NullPointerException
	at Main.main(Main.java:10)
```

Which object? `user`, `getAddress()`, or `getCity()`? You’d need to debug line-by-line or use logging, wasting valuable
development time.

This lack of clarity made NPEs notoriously hard to debug and often led to defensive programming or overuse of null
checks, cluttering the codebase.

## Solution

Starting with **JDK 14**, the JVM can now provide more precise null messages. This is thanks
to [JEP 358: Helpful NullPointerExceptions](https://openjdk.org/jeps/358). When enabled, the JVM tells you exactly which
part of the chain was null:

```java
String name = user.getAddress().getCity().getName();
```

Now outputs:

```shell
Exception in thread "main" java.lang.NullPointerException: Cannot invoke "Address.getCity()" because the return value of "User.getAddress()" is null
	at Main.main(Main.java:10)
```

This enhancement saves time, reduces cognitive load, and makes debugging significantly easier.

To enable this feature, use:

```shell
-XX:+ShowCodeDetailsInExceptionMessages
```

Note: From JDK 15 onward, this flag is **enabled by default**.

## Multiple Examples in Detailed Fashion with Explanation

### Example 1: Simple Chain

```java
class User {
    Address address;

    public Address getAddress() {
        return address;
    }
}

class Address {
    City city;

    public City getCity() {
        return city;
    }
}

class City {
    String name;

    public String getName() {
        return name;
    }
}

public class Main {
    public static void main(String[] args) {
        User user = new User();
        String name = user.getAddress().getCity().getName();
        System.out.println(name);
    }
}
```

### Old Output:

```shell
NullPointerException at Main.java:15
```

### New Output (JDK 15+):

```shell
NullPointerException: Cannot invoke "Address.getCity()" because the return value of "User.getAddress()" is null
```

#### Explanation:

You instantly know that `getAddress()` returned null. No need to guess or step through.

### Example 2: Null in the Middle

```java
User user = new User();
user.address = new Address();
String name = user.getAddress().getCity().getName();
```

### Output:

```shell
NullPointerException: Cannot invoke "City.getName()" because the return value of "Address.getCity()" is null
```

#### Explanation:

Now you know the `getCity()` call returned null. Again, clarity at a glance.

### Example 3: Method Parameter Null

```java
public void printUserName(User user) {
    System.out.println(user.getName());
}
```

If `user` is null, the output will be:

```shell
NullPointerException: Cannot invoke "User.getName()" because "user" is null
```

#### Explanation:

The JVM now tells you the name of the null variable, not just that an NPE occurred.

## Best Practices

* **Upgrade to JDK 15+** to get helpful NPE messages by default.
* **Use meaningful variable names** to make error messages even more helpful.
* **Refactor deep call chains** to isolate null-prone code.
* **Write unit tests** that validate objects and avoid `null` unless truly necessary.

## Anti Patterns

* **Blind null checks everywhere**:

  ```java
  if (user != null && user.getAddress() != null && user.getAddress().getCity() != null)
  ```

  Clutters code and hides real problems.

* **Swallowing NPEs silently**:

  ```java
  try {
      user.getName();
  } catch (NullPointerException e) {
      // do nothing
  }
  ```

  Leads to hidden bugs and undefined behavior.

* **Ignoring the feature**: Continuing to use old JDKs or disabling the flag without reason misses out on huge
  productivity benefits.

## Final Thoughts

Java’s improved `NullPointerException` messages are a huge leap forward in developer experience. No more cryptic errors
or time wasted debugging call chains. With clearer messages, developers can fix bugs faster and write cleaner code.
Embrace this feature in your JDK upgrade journey—it’s small, but mighty.

## Summary

* Before JDK 14: NPE messages were vague.
* JDK 14 introduced helpful NPE messages (JEP 358).
* From JDK 15+: Enabled by default.
* Pinpoints the exact null variable in method chains.
* Greatly improves debugging efficiency.
* Avoid anti-patterns and embrace best practices.

## Good Quote

> "Good error messages don't just tell you that something is wrong—they help you fix it."



That's it for today, will meet in next episode.  
Happy coding 😁
