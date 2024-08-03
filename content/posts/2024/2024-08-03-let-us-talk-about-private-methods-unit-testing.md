---
title : 'Let Us Talk About Private Methods Unit Testing'
author: Abhishek
type: post
date : 2024-08-03T17:30:10+05:30
url: "/let-us-talk-about-private-methods-unit-testing/"
images: ["/preview-images/private-method-unit-testing.webp"]
toc: true
draft : false
categories: [testing]
tags: [unit testing]
---

## Introduction

In this blog, we will talk about private methods unit testing, Nowadays, unit testing is just become formality in teams to increase code coverage only by writing
any type of unit test code, which is not good.

I have seen developers are writing unit test code for each and every production code method
whether it is private or public method, which is not good.

**You should test the behaviour not the code** that's why you should write test by keeping in mind
public methods and try to cover all cases, but suppose if your private method is having very complex
logic, and you want to test that private method in isolation manner, then I have seen developers uses 
reflection to test that private method which is note efficient approach because if you change signature of
your private method then your compiler will not tell.

{{< box warning >}}
**Important Note:**

It is not recommend to write test for private method because **you should write test for the behaviour 
but not for the code**. 

But if your private method is too complex, and you would like to test it in isolation manner then
**don't use reflection to write test for it**, use below explained technique.
{{< /box >}}

## Private Method Unit Testing Approach One

### Example

```java
package com.amalvadkar.processor;

import com.amalvadkar.dto.FeedbackDTO;
import com.google.common.annotations.VisibleForTesting;

public class FeedbackProcessor {

    public String process(FeedbackDTO feedbackDTO) {
        // some logic
        boolean isFeedbackCompliance = checkFeedbackCompliance(feedbackDTO);
        if (isFeedbackCompliance){
            return "Feedback Processed Successfully";
        } else {
            return "Feedback is not compliance";
        }
    }

    @VisibleForTesting
    public boolean checkFeedbackCompliance(FeedbackDTO feedbackDTO) { // Made it public to test
        boolean isFeedbackCompliance = false;
        // more complex logic and decide isFeedbackCompliance boolean value
        return isFeedbackCompliance;
    }

}
```

```java
package com.amalvadkar.dto;

public record FeedbackDTO(String content, Long createdById) {
}
```

```java
package com.amalvadkar.processor;

import com.amalvadkar.dto.FeedbackDTO;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class FeedbackProcessorTest {

    @Test
    void feedback_should_process() {
        FeedbackProcessor feedbackProcessor = new FeedbackProcessor();
        String result = feedbackProcessor.process(new FeedbackDTO("Good content !!", 1L));
        assertThat(result).isEqualTo("Feedback Processed Successfully");
    }

    @Test
    void should_return_true_as_feedback_is_compliance() {
        FeedbackProcessor feedbackProcessor = new FeedbackProcessor();
        boolean result = feedbackProcessor.checkFeedbackCompliance(new FeedbackDTO("Good content !!", 1L));
        assertThat(result).isTrue();
    }
}
```

In above example, you can see, to test private method we made it public and added **@VisibleForTesting
annotation from google guava** which will indicate to developer that this method is public only for
testing don't call this method in production code.

{{< box warning >}}
**Important Note:**

**@VisibleForTesting will not prevent to developer from calling your method**, it is just for
information that's why approach one is not full proof, let us see approach two. 
{{< /box >}}

## Private Method Unit Testing Approach Two

As developer is able to call our private method from anywhere because we made it public, so only one tiny change
in approach one to make it full proof so developer will not call our method from anywhere.

We need to make our private method as **package private (default)** so it will be accessible from only same
package, and we know production and test code classes have same package name.

### Example

```java
package com.amalvadkar.processor;

import com.amalvadkar.dto.FeedbackDTO;
import com.google.common.annotations.VisibleForTesting;

public class FeedbackProcessor {

    public String process(FeedbackDTO feedbackDTO) {
        // some logic
        boolean isFeedbackCompliance = checkFeedbackCompliance(feedbackDTO);
        if (isFeedbackCompliance){
            return "Feedback Processed Successfully";
        } else {
            return "Feedback is not compliance";
        }
    }

    @VisibleForTesting
    boolean checkFeedbackCompliance(FeedbackDTO feedbackDTO) { // package-private method
        boolean isFeedbackCompliance = false;
        // more complex logic and decide isFeedbackCompliance boolean value
        return isFeedbackCompliance;
    }

}
```

```java
package com.amalvadkar.dto;

public record FeedbackDTO(String content, Long createdById) {
}
```

```java
package com.amalvadkar.processor;

import com.amalvadkar.dto.FeedbackDTO;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class FeedbackProcessorTest {

    @Test
    void feedback_should_process() {
        FeedbackProcessor feedbackProcessor = new FeedbackProcessor();
        String result = feedbackProcessor.process(new FeedbackDTO("Good content !!", 1L));
        assertThat(result).isEqualTo("Feedback Processed Successfully");
    }

    @Test
    void should_return_true_as_feedback_is_compliance() {
        FeedbackProcessor feedbackProcessor = new FeedbackProcessor();
        boolean result = feedbackProcessor.checkFeedbackCompliance(new FeedbackDTO("Good content !!", 1L));
        assertThat(result).isTrue();
    }
}
```


{{< box info >}}
**Important Note:**

Now our method will be used in same package only and by doing this we can also **minimize visibility**,
and we are able to test it also **without reflection**.

{{< /box >}}

Happy coding :grinning:
