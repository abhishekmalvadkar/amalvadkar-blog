---
title: 'Compression: A the Silent Hero of Scalable Systems'
author: Abhishek
type: post
date: 2025-06-04T11:48:02+05:30
url: "/compression-a-the-silent-hero-of-scalable-systems/"
toc: true
draft: false
categories: [ "system design" ]
tags: [ "compression" ]
---

A few years ago, I was working on an e-commerce application for a festive sale event. Everything was running smoothly in
development, but during peak traffic on production, the APIs started responding sluggishly. Our Redis cache usage
exploded, image-heavy product listings loaded slowly, and our logs consumed more disk space than expected.

We sat down, profiled everything, and discovered an overlooked but powerful optimization: **compression**.

From large JSON payloads to cached values and static files, we hadn’t applied compression effectively. After
implementing it at various levels, the system not only stabilized but performed **40% better**, with improved speed and
drastically reduced costs.

## Problem

Modern systems deal with a vast amount of **data movement and storage**. Whether it's user-uploaded files, images, API
responses, or cached values, they all consume bandwidth, memory, and disk.

Here are typical issues:

* Large API responses slow down network throughput.
* Redis caches get bloated quickly, raising infrastructure costs.
* User-uploaded files take more space and slow down retrieval.
* Logs and backups consume extensive disk resources.
* Image-heavy websites suffer from high load time and poor UX.

Ignoring compression can lead to:

* **Higher latency**
* **More resource consumption**
* **Higher cloud costs**
* **Poor scalability**
* **Bad user experience**

## Solution

Compression reduces data size **without losing meaning or value**, making it a vital design principle for
performance-sensitive systems.

Java and its ecosystem offer multiple techniques and libraries to apply compression **at various levels**, such as:

* HTTP layer compression (GZIP, Brotli)
* Redis value compression using Snappy or LZ4
* Log compression using log rotation tools
* File and image compression (ZIP, WebP)
* Database column compression (via custom logic or binary storage)

## Multiple Examples with Explanation

### 1. API Response Compression (GZIP/Brotli)

**Before Compression:**
An API returning 200 KB of JSON for each product list call.

**After Compression:**
With GZIP compression at server level:

* JSON shrinks to \~40 KB.
* 80% faster response perceived by clients.
* Bandwidth savings with just 1 config change in Spring Boot:

```yaml
server:
  compression:
    enabled: true
    mime-types: application/json,application/xml,text/html,text/xml,text/plain
    min-response-size: 1024
```

### 2. Redis Cache Compression

**Problem:** Storing large serialized Java objects (e.g., product catalog).
**Solution:** Use a compression library like `Snappy`, `LZ4`, or `GZIP`:

```java
byte[] compressedValue = Snappy.compress(serialize(myObject));
redisTemplate.opsForValue().set("key",compressedValue);
```

**Benefit:** Reduces cache size by 50–70%, lowering cache eviction and Redis memory cost.

### 3. File Compression (ZIP, TAR.GZ)

User uploads large reports or backups.

**Solution:** Compress files before storing or sending:

```java
try (ZipOutputStream zipOut = new ZipOutputStream(new FileOutputStream("compressed.zip"))) {
    ZipEntry zipEntry = new ZipEntry("report.csv");
    zipOut.putNextEntry(zipEntry);
    Files.copy(Paths.get("report.csv"),zipOut);
}
```

**Usage:**

* Exported reports
* Email attachments
* Archival purposes

### 4. Image Compression (WebP, AVIF)

**Problem:** PNG/JPEG images slow down page load.

**Solution:** Convert to WebP format, which is \~30% smaller:

* Use tools like `ImageMagick`, `libwebp`, or integrate a CDN like Cloudflare or ImageKit.

**Benefits:**

* Faster website
* SEO boost
* Lower storage

### 5. Log Compression and Rotation

**Problem:** Text-based logs grow rapidly.

**Solution:** Use `logback` or `log4j2` with rollover + compression:

```xml

<rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
    <fileNamePattern>logs/app.%d{yyyy-MM-dd}.gz</fileNamePattern>
</rollingPolicy>
```

**Outcome:**

* 90% smaller logs
* Efficient archiving

### 6. Database Column Compression

**Use Case:** Large string columns or JSON fields in MySQL/Postgres.

**Solution:** Store compressed binary blobs or use `BASE64(GZIP(data))`.

* For reporting-heavy fields, compress JSON before saving.
* Decompress in application layer.

### 7. Kafka Message Compression

Kafka supports `snappy`, `lz4`, `gzip` compression:

```properties
compression.type=snappy
```

**Impact:**

* Lower disk I/O
* Faster replication
* Smaller payloads across network

### 8. Frontend Asset Compression

**Use Case:** Minified + compressed JS/CSS

* Use `Webpack`, `Rollup`, or `Parcel` to compress and minify.
* Serve GZipped assets via CDN/Edge layer.

## Best Practices

* Apply **compression at edge** (API gateway, CDN) to reduce latency.
* Monitor compression ratio – avoid compressing already compressed data.
* Choose compression based on use-case (speed vs ratio).
* Prefer stateless compression mechanisms (Snappy for in-memory, GZIP for disk).
* Use `ETag` and `Cache-Control` headers with compression for caching benefit.

## Anti Patterns

* Compressing already compressed files (e.g., GZIP inside ZIP).
* Applying heavy compression on small payloads (adds CPU overhead).
* Not versioning compressed files (hard to debug).
* Compressing on every request instead of caching the compressed version.

## Recommended Book

* **“Designing Data-Intensive Applications” by Martin Kleppmann** – Covers performance trade-offs with storage,
  encoding, and compression in depth.
* **“High Performance Browser Networking” by Ilya Grigorik** – Great insights on compression at API and frontend levels.

## Final Thoughts

Compression is a low-hanging fruit in system design that pays off immensely in the long run. It directly improves speed,
scalability, and cost-efficiency. The key is to strategically place compression where data flows the most — APIs,
caches, disks, and networks.

## Summary

```shell
| Area            | Compression Type | Tool/Tech               | Benefit                      |
|-----------------|------------------|-------------------------|------------------------------|
| API             | GZIP/Brotli      | Spring Boot, NGINX      | Smaller response size        |
| Redis           | Snappy/LZ4       | Manual in Java code     | Reduced cache memory         |
| Files           | ZIP              | Java Zip APIs           | Less disk usage              |
| Images          | WebP/AVIF        | ImageMagick, CDN        | Faster UX                    |
| Logs            | GZIP             | Logback/log4j2 rotation | Archival and size efficiency |
| DB Column       | Custom           | Base64+GZIP             | Compact large fields         |
| Kafka           | Snappy/GZIP      | Kafka config            | Efficient message handling   |
| Frontend Assets | GZIP             | Webpack/CDN             | Improved page load time      |
```
> “Compression is the cheapest form of optimization. It doesn’t require more servers—just smarter bytes.”  
> — Unknown

**That's it for today, will meet in next episode.**

**Happy coding 😀**


