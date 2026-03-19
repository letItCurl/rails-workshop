---
branch: 14-hackathon
title: "Hackathon — พิสูจน์ตัวเอง"
lang: th
pair: guide-en.md
day: 2
time: "13:45–16:00"
duration: 135min
difficulty: "\U0001F534 Challenge"
prerequisite: 13-stimulus
next: 15-deploy
aha_moment: "ฉันทำ Business → DB → Code ได้เองแล้ว"
---

# Hackathon — พิสูจน์ตัวเอง

> 2 ชั่วโมง. Business → Database → Code. พิสูจน์ว่าคุณทำได้

ถึงเวลาแล้ว ตลอด 2 วันที่ผ่านมา เราพาคุณเดินทีละขั้น ตอนนี้คุณจะเดินเอง

---

## กฎ

1. **จับทีม 3–4 คน** — คละระดับประสบการณ์
2. **เลือก Feature จากเมนูด้านล่าง** — ทีมละ 1 feature
3. **วาด ERD บนกระดาษก่อน** — Facilitator ต้องเช็คก่อนจะเริ่มเขียนโค้ดได้
4. **สร้าง Feature** — ลงมือเขียนโค้ดจริง
5. **Test ต้องผ่าน** — Feature ยังไม่เสร็จจนกว่า test จะผ่าน
6. **Demo** — 3 นาทีต่อทีม

---

## เมนู Feature

| # | Feature | ความยาก | สิ่งที่ได้เรียนรู้ | Doc |
|---|---------|---------|-------------------|-----|
| 1 | **Like System** | 🟢 Easy | Polymorphic associations, counter | [like-system.md](features/like-system.md) |
| 2 | **Bookmarks** | 🟡 Medium | `has_many :through`, join table | [bookmarks.md](features/bookmarks.md) |
| 3 | **Real-time Comment Notifications** | 🟡 Medium | Callbacks, Turbo Streams broadcast | [realtime-comments.md](features/realtime-comments.md) |
| 4 | **User Avatars** | 🟢 Easy | Active Storage, image processing | [avatars.md](features/avatars.md) |
| 5 | **Joke Bot** | 🟢 Easy | Solid Queue, recurring jobs | [joke-bot.md](features/joke-bot.md) |

---

## การ Demo

- **3 นาทีต่อทีม** — ไม่มีต่อเวลา
- โชว์ ERD ที่วาดบนกระดาษ
- โชว์โค้ดที่เขียน
- รัน test ให้ดู
- **Feature ยังไม่เสร็จจนกว่า test จะผ่าน**

---

## Timeline

| เวลา | กิจกรรม |
|-------|---------|
| 13:45–14:00 | จับทีม + เลือก Feature + วาด ERD |
| 14:00–15:30 | สร้าง Feature |
| 15:30–16:00 | Demo |

---

ขอให้สนุก — นี่คือช่วงเวลาที่คุณจะพิสูจน์ว่าคุณทำได้เอง
