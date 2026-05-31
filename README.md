# TravelPlus

แอพวางแผนทริปส่วนตัว (My Trip App) สำหรับบันทึกแผนเที่ยว ตารางรายวัน สถานที่อยากไป งบประมาณ เช็คลิสต์ และความทรงจำ

## ✨ Features

- **Trips Management** — สร้างและจัดการหลายทริป พร้อมสถานะ (Planning / Traveling / Completed)
- **Daily Plans** — เพิ่มกิจกรรมรายวันพร้อมเวลา ประเภท ค่าใช้จ่าย และสถานะ
- **Saved Places** — เก็บสถานที่ที่อยากไป (รองรับลิงก์ Google Maps หรือพิกัด lat,lng)
- **Budget Tracking** — จัดการงบประมาณและรายจ่ายตามหมวดหมู่
- **Checklist** — เช็คลิสต์แบบ Global + ต่อทริป
- **Local Storage** — บันทึกข้อมูลด้วย Hive (ข้อมูลอยู่ถาวรในเครื่อง)
- **Google Maps Integration** — สามารถใส่ลิงก์หรือพิกัดและเปิดแผนที่ได้โดยตรง

## 🛠 Tech Stack

- Flutter 3.24+
- Hive + Hive Generator (Local Database)
- url_launcher (เปิด Google Maps)
- build_runner (Code Generation)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (แนะนำเวอร์ชัน stable ล่าสุด)
- Android Studio / VS Code + Flutter Extension
- สำหรับ iOS: ต้องมี Mac + Xcode (หรือใช้ Codemagic)

### Installation

```bash
git clone <your-repo-url>
cd TravelPlus
flutter pub get
```

### Generate Code (สำคัญมาก)

เพราะใช้ Hive + build_runner ต้องรันคำสั่งนี้ทุกครั้งที่มีการแก้ไข model:

```bash
dart run build_runner build --delete-conflicting-outputs
```

หรือใช้ watch mode ขณะพัฒนา:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Run the App

```bash
# Android
flutter run

# iOS (ต้องมี Mac)
flutter run

# Web
flutter run -d chrome

# Linux Desktop
flutter run -d linux
```

## 📁 Project Structure

```
lib/
├── main.dart
├── models/                  # Data models + Hive adapters
├── data/local/              # Hive service
├── screens/                 # Global views (Places, Checklist, Settings)
├── core/utils/              # Helper functions (เช่น Maps utils)
└── widgets/                 # Reusable widgets (ถ้ามี)
```

## 🔄 CI/CD

โปรเจกต์มีไฟล์ `codemagic.yaml` สำหรับ build iOS ผ่าน [Codemagic](https://codemagic.io)

- รัน `build_runner` อัตโนมัติ
- Build IPA
- สามารถตั้งค่าให้ upload ไป TestFlight ได้

> **หมายเหตุ**: โปรเจกต์นี้ยังไม่มีโฟลเดอร์ `ios/` อยู่ใน repository  
> คุณต้องรันคำสั่งนี้บน Mac เพื่อสร้างโฟลเดอร์ iOS ก่อน:
> ```bash
> flutter create . --platforms=ios
> ```

## 📝 Notes

- ข้อมูลทั้งหมดถูกเก็บในเครื่อง (Local only) ด้วย Hive
- ยังไม่มีระบบ Login / Cloud Sync (เหมาะสำหรับ MVP)
- รองรับทั้ง Android และ iOS (หลังจากเพิ่มโฟลเดอร์ iOS)

## 📌 Roadmap (ตาม AGENTS.md)

- [x] Local storage ด้วย Hive
- [x] Google Maps link support
- [ ] Export ทริปเป็น PDF
- [ ] แผนที่ (Google Maps integration แบบเต็ม)
- [ ] Cloud sync (อนาคต)

## 🤝 Contributing

ยินดีต้อนรับ Pull Request!  
ก่อนส่ง PR กรุณารัน `build_runner` และตรวจสอบว่า build ผ่านทั้ง Android และ iOS

---

**Made with ❤️ for personal trip planning**