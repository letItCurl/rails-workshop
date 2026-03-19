---
branch: 15-deploy
title: "Deploy — แอปคุณอยู่บน Internet"
lang: th
pair: guide-en.md
day: 2
time: "16:00–16:15"
duration: 15min
difficulty: 🟢 Recipe
prerequisite: 14-hackathon
next: null
aha_moment: "จาก rails new ถึง production ใน 2 วัน"
business_rule: "Stretch goal — ถ้า VM พร้อม"
---

# 🚀 Deploy — 3 คำสั่ง แล้วลาก่อน

15 นาทีสุดท้าย แอปที่คุณสร้าง 2 วัน กำลังจะอยู่บน internet

**ไม่มีคำอธิบาย Docker ไม่มีคำอธิบาย Kamal ไม่มี DevOps theory แค่ทำตาม แล้วมันจะ work**

---

## เตรียมตัว

VM ของคุณพร้อมแล้วที่: `your-team.oddlyhonest.dev`

ตรวจสอบว่า SSH เข้าได้:

```bash
ssh deploy@your-team.oddlyhonest.dev "echo connected"
```

---

## Deploy

### Step 1: Configure

เปิด `config/deploy.yml` แล้วแก้:

```yaml
service: oddly-honest
image: your-team/oddly-honest

servers:
  web:
    hosts:
      - your-team.oddlyhonest.dev
    options:
      network: "host"

proxy:
  ssl: true
  host: your-team.oddlyhonest.dev

registry:
  server: ghcr.io
  username: your-github-username
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  secret:
    - RAILS_MASTER_KEY
    - DATABASE_URL
```

### Step 2: Setup

```bash
kamal setup
```

รอ... Docker install, image build, push, pull, start ทั้งหมดอัตโนมัติ

### Step 3: Deploy

```bash
kamal deploy
```

---

## เปิด Browser

ไปที่ `https://your-team.oddlyhonest.dev`

**แอปคุณอยู่บน internet** จาก `rails new` ถึง production ใน 2 วัน

---

## 🎉 จบแล้ว

คุณเริ่มจาก "ทำไมต้อง Rails?" ตอนนี้คุณ:

- สร้างแอปจาก scratch
- เข้าใจ database-first thinking
- เขียน business rules + tests
- Master has_many :through
- ใช้ Turbo Frames + Streams (zero JS)
- สร้าง Stimulus controllers
- Build feature เองใน hackathon
- Deploy ขึ้น production

**ทักษะที่ AI แทนไม่ได้: เข้าใจปัญหา → model database → ที่เหลือตามมา**

ขอบคุณ 🙏
