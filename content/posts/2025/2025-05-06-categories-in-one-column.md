---
title : 'Categories in One Column'
author: Abhishek
type: post
date : 2025-05-06T11:17:29+05:30
url: "/2025-05-06-categories-in-one-column/"
toc: true
draft : false
categories: ["mysql", "database design"]
tags: ["mysql", database design]
---

# Why You Should Avoid Storing Multiple Categories in a Single MySQL Column

In many applications — like e-commerce, blogging platforms, or service marketplaces — items often belong to more than one category. A common but problematic design choice is to store these multiple categories in a single column using a delimiter like a semicolon.

For example:

```sql
+----+-------------------------+
| id | categories              |
+----+-------------------------+
| 1  | Auto Detailing;Automotive |
| 2  | Health;Wellness         |
| 3  | Software;Technology     |
+----+-------------------------+
```

At first glance, this approach seems simple and convenient. But as your application grows, this "denormalized" design introduces significant issues.

---

## ✅ The Use Case: Why This Happens

You might do this when:

- You want to move fast and prototype quickly.
- You don’t want the complexity of designing multiple tables.
- You think full-text search or simple filtering is enough.
- You’re storing data coming from a third-party API in a quick, flat format.

This can work temporarily for small applications, but it’s not scalable or maintainable.

---

## ❌ The Problems with This Approach

### 1. **Difficult to Query**

Want to find all items under the `Automotive` category?

You’d need to use `LIKE`, which is slow and error-prone:

```sql
SELECT * FROM items WHERE categories LIKE '%Automotive%';
```

This might also match `Auto Detailing` accidentally if not handled properly.

---

### 2. **No Referential Integrity**

You can't create a foreign key on the `categories` column, so there's no guarantee the values are valid. Typos like `Automtive` will silently creep in.

---

### 3. **Filtering and Indexing is Inefficient**

Indexes are useless when querying parts of a delimited string. Your queries will be slow.

---

### 4. **Harder to Update or Delete**

What if you want to remove `Auto Detailing` from an item?

You'd need string manipulation:

```sql
UPDATE items SET categories = REPLACE(categories, 'Auto Detailing;', '') WHERE id = 1;
```

Messy and risky — what if the category is in the middle, start, or end?

---

## ✅ A Better Design: Normalize It

Instead of storing multiple values in one column, use a **many-to-many relationship**.

### 🧱 Database Schema

```text
+--------+         +----------------+        +-------------+
| items  |         | item_categories|        | categories  |
+--------+         +----------------+        +-------------+
| id     |◄───────►| item_id        |        | id          |
| name   |         | category_id    |◄──────►| name        |
+--------+         +----------------+        +-------------+
```

### ✅ Example Data

**items**
```text
id | name
---|-------------
1  | Car Polish Kit
2  | Meditation App
```

**categories**
```text
id | name
---|-------------
1  | Auto Detailing
2  | Automotive
3  | Health
4  | Wellness
```

**item_categories**
```text
item_id | category_id
--------|-------------
1       | 1
1       | 2
2       | 3
2       | 4
```

---

### 💡 Benefits of This Approach

- Easy to query:
  ```sql
  SELECT i.* 
  FROM items i
  JOIN item_categories ic ON i.id = ic.item_id
  JOIN categories c ON c.id = ic.category_id
  WHERE c.name = 'Automotive';
  ```

- Enforces valid categories with foreign keys.
- Clean and performant joins.
- Easy to add/remove relationships.

---

## ✨ Final Thoughts

While storing multiple categories in one column **may seem convenient at first**, it causes performance, maintenance, and data integrity issues in the long run. A normalized approach with join tables not only future-proofs your design but also keeps your queries fast and manageable.

**So if you're tempted to use `categories = 'A;B;C'`, take a step back and ask: What will future-you thank you for?**

---

## 📌 Tip for Migrating

If you already have this kind of column, you can split the data and insert it into a join table using something like:

```sql
-- Pseudo-query: you’d use a script or stored procedure in practice
INSERT INTO item_categories (item_id, category_id)
SELECT i.id, c.id
FROM items i
JOIN categories c ON FIND_IN_SET(c.name, REPLACE(i.categories, ';', ',')) > 0;
```

That's it for today, will meet in the next episode.

Happy coding :grinning:

