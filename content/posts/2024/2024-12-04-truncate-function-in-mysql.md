---
title : 'Truncate Function In MySQL'
author: Abhishek
type: post
date : 2024-12-04T00:00:00+05:30
url: "/truncate-function-in-mysql/"
toc: true
draft : false
categories: [mysql]
tags: [mysql]
---

In this blog we will see real world usecase of mysql truncate function.


# Real-World Example of MySQL `TRUNCATE()` Function

The `TRUNCATE()` function in MySQL is used to truncate a numeric value to the specified number of decimal places without rounding.

## Scenario: Financial Reporting
In financial systems, precise reporting is essential, but sometimes, reports are required to show values up to a certain number of decimal places without rounding.

## Example
Imagine you are working on an application that processes interest calculations for a bank. The interest rate calculations may produce values with several decimal places, but for reporting purposes, the bank wants to display only two decimal places without rounding.

### Database Setup
```sql
CREATE TABLE InterestCalculations (
    AccountID INT,
    InterestEarned DECIMAL(10, 5)
);

INSERT INTO InterestCalculations (AccountID, InterestEarned)
VALUES 
(1, 123.45678),
(2, 89.12345),
(3, 56.78912);
```

### Query with `TRUNCATE()`
You can use the `TRUNCATE()` function to limit the decimal places for reporting:

```sql
SELECT 
    AccountID, 
    InterestEarned,
    TRUNCATE(InterestEarned, 2) AS TruncatedInterest
FROM 
    InterestCalculations;
```

### Result
{{< responsive-table >}}

| AccountID | InterestEarned | TruncatedInterest |
|-----------|----------------|-------------------|
| 1         | 123.45678      | 123.45            |
| 2         | 89.12345       | 89.12             |
| 3         | 56.78912       | 56.78             |

{{< /responsive-table >}}

## Use Case Explanation
1. **Precise Display:** The truncated values are displayed as per the bank's requirements, ensuring no rounding occurs.
2. **Consistency:** Ensures consistent formatting in reports while retaining original precision in the database for other calculations.

This approach ensures transparency and reliability in financial reporting systems.



Happy coding :grinning:
