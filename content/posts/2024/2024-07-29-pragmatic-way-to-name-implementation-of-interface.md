---
title : 'Pragmatic Way to Name Implementation of Interface'
author: Abhishek
type: post
date : 2024-07-29T10:46:15+05:30
url: "/pragmatic-way-to-name-implementation-of-interface/"
images: ["/preview-images/better-interface-implementation-name.webp"]
toc: true
draft : false
categories: ["Clean Code And Refactoring"]
tags: ["naming-is-hard"]
---

In this blog, we will see different approaches of 
naming implementation class of any interface.

I have seen developers create interface even they have only one implementation,
which is big mistake, **don't create interface if you have only one implementation
class** because it will be too verbose to maintain

Now suppose if you need another implementation then, nowadays it is easy
to extract interface from class within fraction of seconds using IDEs.

Let's see different approaches of naming implementation class

## Impl approach

### Example 

```java
public interface EmailService {
    void sendEmail(EmailDTO emailDTO);
}
```

```java
public record EmailDTO(String subject , String from, String to, String htmlEmailBody) {
}
```

```java
public class EmailServiceImpl implements EmailService {
 
    @Override
    public void sendEmail(EmailDTO emailDTO) {
        // Email send logic
    }
}
```

As you can see in above example, we have named implementation class
as EmailServiceImpl which is known as impl approach.

### Advantages of impl approach

* We don't need to think to much in order to give name
* It's good if you have only one implementation class but why we should use interface if you have only one implementation class right ?

### Disadvantages of impl approach

* If you want to introduce another implementation then what name you will give to that new implementation class, **EmailServiceImpl2 ? which is not readable** 
* If you have multiple implementation class then this approach will makes your code less readable 

{{< box warning >}}
**Important Note:**

If you have only one implementation then don't create interface.

In the future, if you need more then one implementation class then use IDE refactoring technique 
to extract interface from class and **don't even think about to use this approach to name those
implementation classes, use next explained approach**.
{{< /box >}}

## Semantic approach

### Example

```java
public interface EmailService {
    void sendEmail(EmailDTO emailDTO);
}
```

```java
public record EmailDTO(String subject , String from, String to, String htmlEmailBody) {
}
```

```java
public class SimpleEmailService implements EmailService {
 
    @Override
    public void sendEmail(EmailDTO emailDTO) {
        // Using Java Mail Sender API email send logic
    }
}
```

```java
public class SendGridEmailService implements EmailService {
 
    @Override
    public void sendEmail(EmailDTO emailDTO) {
        // Using SendGrid API email send logic
    }
}
```

As you can see in above example, we have named implementation classes
as **SimpleEmailService** and **SendGridEmailService** which is based on the library we are going to use
to send email, which is called **semantic approach means the factor which makes those implementation
different to each other, give name based on that factor**, In our case that factor is 
email send library.

### Advantages of semantic approach

* It makes your code more readable and maintainable
* Suppose if you want to change something in send grid emails send logic then you will directly in SendGridEmailService class and change it, this will be more difficult in impl approach

### Disadvantages of semantic approach

* I can't see any disadvantage of this approach

{{< box tip >}}
**Important Note:**

If you have more then one implementation then this is recommended approach

I know naming is hard but try to find that differentiate factor before choosing your implementation
class name and based on that factor only finalize your implemetation class name
{{< /box >}}

Happy coding :grinning:



