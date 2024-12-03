---
title : 'MySQL Weekly Newsletter - 1'
author: Abhishek
type: post
date : 2024-12-03T00:00:00+05:30
url: "/mysql-weekly-newsletter-1/"
toc: true
draft : false
categories: [mysql weekly newsletter]
tags: [mysql weekly newsletter]
---

In this blog we will see usefull mysql blogs that we have found in this week.

Please feel free to read these nice blogs in order to extend your mysql skills.

## MySQL RAND() Function

### Blog

[MySQL RAND() Function](https://www.mysqltutorial.org/mysql-math-functions/mysql-rand/)

### POC

* Create motivation quotes table
* Insert some entries
* Create custom MySQL function called rand_between(minInt, maxInt)
* Create stored procedure which will give you random quote from quotes table
* Inside stored procedure use rand_between() function on min quoteId and max quoteId

### Solution Hint

<details>
  <summary style="cursor: pointer; font-weight: bold;">▶ Click to expand and view the solution</summary>
  
```sql
set @minQuoteId = (select min(q.id) from quote q);
set @maxQuoteId = (select max(q.id) from quote q);
set @rand_quote_id = (select rand_between(
	@minQuoteId, @maxQuoteId
));

select * from quote q where q.id = @rand_quote_id;
```
</details>


Happy coding :grinning:
