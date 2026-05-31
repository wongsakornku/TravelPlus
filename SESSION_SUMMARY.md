# TravelPlus - Session Summary (สำหรับย้ายไป Mac)

**วันที่สรุป:** 31 พฤษภาคม 2026

## สถานะปัจจุบันของโปรเจกต์

- โปรเจกต์: **TravelPlus** (แอพวางแผนทริปส่วนตัว)
- ใช้ **Flutter**
- ใช้ **Hive** สำหรับเก็บข้อมูลถาวรในเครื่อง (แทน in-memory)
- รองรับ **Google Maps Link** ใน Saved Places (ทั้ง URL และ lat,lng)
- มี Global Places + Global Checklist (นอกเหนือจาก per-trip)
- มี `codemagic.yaml` สำหรับ build iOS
- ปัจจุบัน **ไม่มีโฟลเดอร์ `ios/`** ใน repository (ปัญหาหลัก)

## สิ่งที่แก้ไข/เพิ่มเข้ามาใน session นี้

### 1. Dependency Fixes
- Downgrade `build_runner` จาก `^2.4.15` → `^2.4.13` เพื่อแก้ปัญหาเข้ากันไม่ได้กับ `hive_generator ^2.0.1`
- รัน `flutter pub get` สำเร็จหลังแก้

### 2. Google Maps UX Improvements
- เพิ่มปุ่มเปิด Google Maps โดยตรงในฟอร์มเพิ่มสถานที่
- รองรับการกรอกพิกัด `lat,lng` โดยตรง (ระบบจะแปลงเป็น URL ให้อัตโนมัติ)
- ปรับปุ่ม "เปิดแผนที่" ใน Place Card ให้เด่นขึ้น (ใช้ OutlinedButton)

### 3. โครงสร้างโค้ด
- แยก Models ออกเป็นโฟลเดอร์ `lib/models/`
- แยก Global Views ออกเป็น `lib/screens/`
- สร้าง `lib/core/utils/maps_utils.dart` (ช่วยเรื่อง normalize URL และเปิด Maps)

### 4. CI/CD
- สร้าง `codemagic.yaml` (เวอร์ชัน build IPA อย่างเดียว)
- สร้าง `ios/ExportOptions.plist`

## ปัญหาหลักที่ยังค้างอยู่

**ไม่มีโฟลเดอร์ `ios/`** → ทำให้ Codemagic build iOS ไม่ได้

## สิ่งที่ต้องทำบน Mac (เรียงลำดับความสำคัญ)

### ขั้นตอนเร่งด่วน
1. Clone โปรเจกต์ลง Mac
2. รันคำสั่งสร้าง iOS platform:
   ```bash
   flutter create . --platforms=ios
   ```
3. ติดตั้ง CocoaPods:
   ```bash
   cd ios && pod install && cd ..
   ```
4. Generate code (สำคัญ):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
5. Commit และ Push โฟลเดอร์ `ios/`:
   ```bash
   git add ios/
   git commit -m "feat: add iOS platform support"
   git push
   ```

### หลังจาก Push เสร็จ
- กลับไปที่ Codemagic → Rebuild โปรเจกต์ใหม่
- ตั้งค่า **Code Signing** (สำคัญที่สุดสำหรับ iOS)
  - แนะนำใช้ Automatic code signing ก่อน
  - ต้องมี Apple Developer Account + Team ID

## ไฟล์สำคัญที่ถูกสร้าง/แก้ไขใน session นี้

| ไฟล์ | สถานะ |
|------|--------|
| `pubspec.yaml` | แก้ build_runner เป็น ^2.4.13 |
| `codemagic.yaml` | สร้างใหม่ (เวอร์ชัน build IPA) |
| `ios/ExportOptions.plist` | สร้างใหม่ |
| `lib/models/` | แยก model ใหม่ทั้งหมด + เพิ่ม @HiveType |
| `lib/data/local/hive_service.dart` | สร้างใหม่ |
| `lib/core/utils/maps_utils.dart` | สร้างใหม่ |
| `SESSION_SUMMARY.md` | ไฟล์นี้ (สรุปสำหรับย้ายเครื่อง) |

## คำสั่งที่ควรจำไว้

```bash
# หลังแก้ model
dart run build_runner build --delete-conflicting-outputs

# ดูสถานะ dependency
flutter pub outdated

# Build Android (ทดสอบ)
flutter build apk --release
```

## หมายเหตุเพิ่มเติม

- ข้อมูลใน workspace Linux นี้ **ไม่สามารถ save session ไปเปิดต่อบน Mac ได้โดยตรง**
- วิธีที่ดีที่สุดคือใช้ **Git** เป็นสะพานเชื่อม
- หลังจากมี `ios/` folder แล้ว ค่อยกลับมาคุยต่อเรื่อง Code Signing + TestFlight

---

**พร้อมทำงานต่อบน Mac เมื่อไหร่ บอกได้เลยครับ**  
ผมสามารถช่วยคุณทีละขั้นตอนได้ (โดยเฉพาะส่วน Code Signing บน Codemagic)