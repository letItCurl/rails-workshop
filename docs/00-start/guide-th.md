---
branch: 00-start
title: "เริ่มต้น — เตรียมตัวก่อน Workshop"
lang: th
pair: guide-en.md
day: 0
difficulty: "🟢 Recipe"
next: 01-foundation
---

# เริ่มต้น — เตรียมตัวก่อน Workshop

## ยินดีต้อนรับสู่ OddlyHonest Workshop!

Workshop นี้จะพาทุกคนสร้าง web app จริงๆ ด้วย Ruby on Rails ตั้งแต่ต้นจนจบ

## ทำไมต้อง Rails?

ตอนนี้หลายคนใช้ React หรือ Next.js อยู่แล้ว ซึ่งก็ดีนะ แต่ลองคิดดูว่า ทุกครั้งที่เริ่มโปรเจกต์ใหม่ เราต้อง wire ทุกอย่างเองหมดเลย — authentication, database, API routes, form handling, validation...

แล้วถ้ามี framework ที่จัดการเรื่องพวกนี้ให้ซัก 80% ล่ะ? เราจะได้โฟกัสกับ business logic จริงๆ แทนที่จะนั่ง setup boilerplate

นั่นแหละคือ Rails ครับ/ค่ะ

## ขั้นตอนการ Setup

### 1. ติดตั้ง Ruby และ Rails

ทำตามขั้นตอนที่ [gorails.com/setup](https://gorails.com/setup) ให้ตรงกับ OS ที่ใช้ (macOS, Ubuntu, Windows)

เว็บนี้จะพาติดตั้งทุกอย่างตั้งแต่ Ruby version manager จนถึง Rails เลย

### 2. ตรวจสอบ Ruby

```bash
ruby -v
```

ควรได้ version 3.2 ขึ้นไป

### 3. ตรวจสอบ Rails

```bash
rails -v
```

ควรได้ version 7.1 ขึ้นไป

### 4. ตรวจสอบ PostgreSQL

เลือกวิธีใดวิธีหนึ่ง:

**วิธี A: ติดตั้งตรงในเครื่อง**

```bash
psql --version
psql -U postgres -c "SELECT 1;"
```

**วิธี B: ใช้ Docker Compose**

```bash
docker compose up -d db
docker compose exec db psql -U postgres -c "SELECT 1;"
```

ถ้าได้ผลลัพธ์กลับมาโดยไม่มี error แสดงว่า PostgreSQL พร้อมใช้งานแล้ว

## Checklist

ก่อนมา workshop ให้เช็คว่าผ่านทุกข้อ:

- [ ] Ruby ติดตั้งแล้ว (version 3.2+)
- [ ] Rails ติดตั้งแล้ว (version 7.1+)
- [ ] PostgreSQL ใช้งานได้ (native หรือ Docker)
- [ ] Clone repo เรียบร้อย
- [ ] Editor พร้อมใช้งาน (VS Code, RubyMine, etc.)

## ขั้นตอนถัดไป

พอ setup เสร็จแล้ว เราจะเริ่มกันที่ **01-foundation** ซึ่งจะพาสร้างโครงสร้างแรกของ app กัน เตรียมตัวให้พร้อมแล้วเจอกันวันจริง!
