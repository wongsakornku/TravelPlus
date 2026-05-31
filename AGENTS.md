# My Trip App

แอพสำหรับวางแผนทริปส่วนตัว ใช้เก็บแผนเที่ยว ตารางรายวัน สถานที่อยากไป งบประมาณ เช็กลิสต์ และบันทึกความทรงจำระหว่างเดินทาง

---

## 1. เป้าหมายของแอพ

My Trip เป็นแอพท่องเที่ยวส่วนตัว ไม่ใช่แอพรีวิวสาธารณะ ผู้ใช้สามารถสร้างทริป วางแผนแต่ละวัน บันทึกสถานที่ ค่าใช้จ่าย และเช็กลิสต์ของตัวเองได้

เหมาะสำหรับ:

- วางแผนเที่ยวคนเดียว
- วางแผนเที่ยวกับครอบครัวหรือเพื่อน
- เก็บสถานที่ที่อยากไป
- จัดงบประมาณทริป
- บันทึกความทรงจำหลังเที่ยว

---

## 2. ฟีเจอร์หลัก

### 2.1 Trips

หน้ารวมทริปทั้งหมดของผู้ใช้

ข้อมูลที่ควรมี:

- ชื่อทริป
- จังหวัด/ประเทศ
- วันที่เริ่มต้น
- วันที่สิ้นสุด
- รูปปกทริป
- สถานะทริป
  - Planning
  - Traveling
  - Completed

ตัวอย่าง:

```text
เชียงใหม่ 3 วัน 2 คืน
วันที่: 12 - 14 ธันวาคม 2026
สถานะ: Planning
```

---

### 2.2 Trip Detail

หน้ารายละเอียดของแต่ละทริป

ควรมีเมนูย่อย:

- Plan
- Places
- Budget
- Checklist
- Memories

---

### 2.3 Daily Plan

ตารางเที่ยวรายวัน เช่น Day 1, Day 2, Day 3

แต่ละรายการควรมี:

- เวลา
- ชื่อกิจกรรมหรือสถานที่
- ประเภท เช่น เดินทาง, ร้านอาหาร, ที่เที่ยว, โรงแรม
- หมายเหตุ
- ค่าใช้จ่ายโดยประมาณ
- สถานะว่าไปแล้วหรือยัง

ตัวอย่าง:

```text
Day 1

09:00 - เดินทางไปสนามบิน
11:30 - ถึงเชียงใหม่
13:00 - กินข้าวร้านอาหารพื้นเมือง
15:00 - ไปคาเฟ่
18:00 - เดินตลาดกลางคืน
```

---

### 2.4 Saved Places

เก็บสถานที่ที่อยากไปก่อน แล้วค่อยนำไปใส่ในแผนเที่ยว

ข้อมูลสถานที่:

- ชื่อสถานที่
- ประเภท
- ที่อยู่
- พิกัด
- เวลาเปิด-ปิด
- หมายเหตุ
- รูปภาพ
- สถานะ
  - อยากไป
  - เพิ่มลงแผนแล้ว
  - ไปแล้ว

ประเภทสถานที่:

- ที่เที่ยว
- ร้านอาหาร
- คาเฟ่
- โรงแรม
- จุดถ่ายรูป
- การเดินทาง
- อื่น ๆ

---

### 2.5 Budget

ระบบจัดการงบประมาณทริป

ข้อมูลที่ควรมี:

- งบทั้งหมด
- ค่าใช้จ่ายจริง
- ยอดคงเหลือ
- หมวดหมู่ค่าใช้จ่าย

หมวดหมู่:

- ค่าเดินทาง
- ที่พัก
- อาหาร
- ค่าเข้าชม
- ช้อปปิ้ง
- อื่น ๆ

ตัวอย่าง:

```text
งบทริปทั้งหมด: 5,000 บาท
ใช้ไปแล้ว: 2,350 บาท
คงเหลือ: 2,650 บาท
```

---

### 2.6 Checklist

เช็กลิสต์ของที่ต้องเตรียมก่อนเดินทาง

ตัวอย่างรายการ:

- บัตรประชาชน
- พาสปอร์ต
- เสื้อผ้า
- ยาประจำตัว
- ที่ชาร์จ
- พาวเวอร์แบงก์
- กล้อง
- เงินสด
- ตั๋วเดินทาง
- ใบจองโรงแรม

แต่ละรายการควรติ๊กว่าเตรียมแล้วหรือยังได้

---

### 2.7 Memories

บันทึกความทรงจำระหว่างหรือหลังเที่ยว

ข้อมูลที่ควรมี:

- วันที่
- รูปภาพ
- ข้อความบันทึก
- คะแนนความประทับใจ
- สถานที่ที่เกี่ยวข้อง

ตัวอย่าง:

```text
วันนี้ไปดอยสุเทพ อากาศดีมาก วิวสวย คนไม่เยอะ
คะแนน: 5/5
```

---

## 3. หน้าจอที่ควรมีในแอพ

### 3.1 Splash Screen

แสดงโลโก้แอพตอนเปิดแอพ

---

### 3.2 Home Screen

แสดงรายการทริปทั้งหมด

องค์ประกอบ:

- ปุ่มสร้างทริปใหม่
- รายการทริปล่าสุด
- ทริปที่กำลังวางแผน
- ทริปที่เที่ยวจบแล้ว

---

### 3.3 Create Trip Screen

หน้าสร้างทริปใหม่

Input:

- ชื่อทริป
- สถานที่
- วันที่เริ่มต้น
- วันที่สิ้นสุด
- งบประมาณ
- รูปปก

---

### 3.4 Trip Detail Screen

หน้ารวมข้อมูลของทริปเดียว

Tab ที่แนะนำ:

- Plan
- Places
- Budget
- Checklist
- Memories

---

### 3.5 Add Plan Item Screen

หน้าเพิ่มกิจกรรมในตารางเที่ยว

Input:

- วันที่
- เวลา
- ชื่อกิจกรรม
- ประเภท
- หมายเหตุ
- ค่าใช้จ่ายโดยประมาณ

---

### 3.6 Add Place Screen

หน้าเพิ่มสถานที่ที่อยากไป

Input:

- ชื่อสถานที่
- ประเภทสถานที่
- ที่อยู่
- หมายเหตุ
- รูปภาพ

---

### 3.7 Add Expense Screen

หน้าเพิ่มค่าใช้จ่าย

Input:

- ชื่อรายการ
- จำนวนเงิน
- หมวดหมู่
- วันที่
- หมายเหตุ

---

### 3.8 Checklist Screen

หน้าจัดการเช็กลิสต์

ฟีเจอร์:

- เพิ่มรายการ
- แก้ไขรายการ
- ลบรายการ
- ติ๊กว่าเตรียมแล้ว

---

### 3.9 Memory Screen

หน้าบันทึกความทรงจำ

ฟีเจอร์:

- เพิ่มรูปภาพ
- เขียนโน้ต
- ให้คะแนนสถานที่หรือวันนั้น
- ดูบันทึกย้อนหลัง

---

## 4. Bottom Navigation ที่แนะนำ

```text
Home | Trips | Budget | Checklist | Settings
```

หรือถ้าอยากเรียบง่าย:

```text
Trips | Places | Budget | Profile
```

---

## 5. โครงสร้างโฟลเดอร์ Flutter

```text
lib/
│
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
│
├── core/
│   ├── constants/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── trips/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
│   │
│   ├── plans/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
│   │
│   ├── places/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
│   │
│   ├── budget/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
│   │
│   ├── checklist/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── services/
│   │
│   └── memories/
│       ├── models/
│       ├── screens/
│       ├── widgets/
│       └── services/
│
└── data/
    ├── local/
    └── repositories/
```

---

## 6. Packages ที่น่าใช้

ไม่จำเป็นต้องใส่ version ในตอนเริ่ม ให้ตรวจเวอร์ชันล่าสุดจาก pub.dev ตอนติดตั้ง

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons:
  intl:
  go_router:
  flutter_riverpod:
  hive:
  hive_flutter:
  image_picker:
  path_provider:
  uuid:
```

### คำอธิบาย

- `intl` ใช้จัดการวันที่และตัวเลข
- `go_router` ใช้จัดการ route
- `flutter_riverpod` ใช้จัดการ state
- `hive` และ `hive_flutter` ใช้เก็บข้อมูลในเครื่อง
- `image_picker` ใช้เลือกรูปจากเครื่อง
- `path_provider` ใช้จัดการ path ไฟล์
- `uuid` ใช้สร้าง id ให้ข้อมูลแต่ละรายการ

---

## 7. Data Models

### 7.1 Trip Model

```dart
class Trip {
  final String id;
  final String title;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final String? coverImagePath;
  final TripStatus status;

  Trip({
    required this.id,
    required this.title,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.budget,
    this.coverImagePath,
    required this.status,
  });
}

enum TripStatus {
  planning,
  traveling,
  completed,
}
```

---

### 7.2 Plan Item Model

```dart
class PlanItem {
  final String id;
  final String tripId;
  final DateTime date;
  final String time;
  final String title;
  final String category;
  final String? note;
  final double estimatedCost;
  final bool isDone;

  PlanItem({
    required this.id,
    required this.tripId,
    required this.date,
    required this.time,
    required this.title,
    required this.category,
    this.note,
    required this.estimatedCost,
    this.isDone = false,
  });
}
```

---

### 7.3 Place Model

```dart
class Place {
  final String id;
  final String tripId;
  final String name;
  final String category;
  final String? address;
  final String? note;
  final String? imagePath;
  final bool isVisited;

  Place({
    required this.id,
    required this.tripId,
    required this.name,
    required this.category,
    this.address,
    this.note,
    this.imagePath,
    this.isVisited = false,
  });
}
```

---

### 7.4 Expense Model

```dart
class Expense {
  final String id;
  final String tripId;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;

  Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });
}
```

---

### 7.5 Checklist Item Model

```dart
class ChecklistItem {
  final String id;
  final String tripId;
  final String title;
  final bool isChecked;

  ChecklistItem({
    required this.id,
    required this.tripId,
    required this.title,
    this.isChecked = false,
  });
}
```

---

### 7.6 Memory Model

```dart
class Memory {
  final String id;
  final String tripId;
  final DateTime date;
  final String note;
  final String? imagePath;
  final int rating;

  Memory({
    required this.id,
    required this.tripId,
    required this.date,
    required this.note,
    this.imagePath,
    required this.rating,
  });
}
```

---

## 8. Route ที่แนะนำ

```dart
final routes = [
  '/',
  '/create-trip',
  '/trip/:id',
  '/trip/:id/add-plan',
  '/trip/:id/add-place',
  '/trip/:id/add-expense',
  '/trip/:id/add-memory',
  '/settings',
];
```

---

## 9. UI Theme

แนวดีไซน์ที่แนะนำ:

- เรียบง่าย
- ใช้ง่ายตอนเดินทาง
- ปุ่มใหญ่ กดง่าย
- สีสบายตา
- ใช้ Card แสดงข้อมูลทริป
- ใช้ Tab สำหรับรายละเอียดทริป

### สีที่แนะนำ

```text
Primary: #FF8A00
Secondary: #FFD180
Background: #FFF8F0
Text: #222222
Success: #4CAF50
Danger: #E53935
```

---

## 10. MVP Version แรก

เวอร์ชันแรกควรทำแค่นี้ก่อน:

- สร้างทริปใหม่
- แสดงรายการทริป
- เพิ่มแผนเที่ยวรายวัน
- เพิ่มสถานที่ที่อยากไป
- เพิ่มค่าใช้จ่าย
- เพิ่มเช็กลิสต์
- บันทึกข้อมูลในเครื่องด้วย Hive

ยังไม่ต้องทำ:

- Login
- Cloud sync
- ระบบแชร์กับเพื่อน
- AI จัดทริป
- ระบบจองโรงแรม
- รีวิวสาธารณะ

---

## 11. Flow การใช้งาน

```text
เปิดแอพ
↓
ดูรายการทริป
↓
สร้างทริปใหม่
↓
เข้า Trip Detail
↓
เพิ่มแผนเที่ยวรายวัน
↓
เพิ่มสถานที่
↓
เพิ่มงบประมาณ
↓
เพิ่มเช็กลิสต์
↓
ระหว่างเที่ยวเพิ่ม Memories
```

---

## 12. Roadmap

### Phase 1: MVP

- Home Screen
- Create Trip
- Trip Detail
- Daily Plan
- Budget
- Checklist
- Local Storage

### Phase 2: Better UX

- เพิ่มรูปปกทริป
- เพิ่มรูปใน Memories
- ค้นหาทริป
- กรองทริปตามสถานะ
- สรุปค่าใช้จ่ายเป็นกราฟ

### Phase 3: Advanced

- แผนที่
- Export ทริปเป็น PDF
- Backup ข้อมูล
- แชร์ทริปให้เพื่อน
- AI ช่วยจัดทริป

---

## 13. ตัวอย่างชื่อแอพ

- My Trip
- Trip Pocket
- Journey Note
- Trip Diary
- My Journey
- เที่ยวของฉัน

---

## 14. สิ่งที่ควรทำใน Android Studio

1. สร้าง Flutter Project ใหม่
2. ตั้งชื่อโปรเจกต์ เช่น `my_trip_app`
3. เพิ่ม dependencies ใน `pubspec.yaml`
4. สร้างโครงสร้างโฟลเดอร์ตามข้อ 5
5. เริ่มจากหน้า Home Screen
6. ทำระบบสร้าง Trip
7. ทำระบบเก็บข้อมูล Local Storage
8. ค่อยเพิ่มฟีเจอร์ Plan, Budget, Checklist และ Memories

---

## 15. หมายเหตุสำหรับการพัฒนา

แอพนี้ควรเริ่มจากการเก็บข้อมูลในเครื่องก่อน เพราะเป็นแอพใช้ส่วนตัว ทำให้พัฒนาได้ง่าย ไม่ต้องมีระบบ Login ในช่วงแรก

เมื่อแอพเริ่มใช้งานได้ดีแล้ว ค่อยเพิ่มระบบ Sync หรือ Backup ภายหลัง
