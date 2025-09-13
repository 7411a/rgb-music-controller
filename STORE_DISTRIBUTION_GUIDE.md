# 📱 RGB Controller App - Store Distribution Guide

## ✅ การเตรียมพร้อมสำหรับ App Store และ Play Store

### 🤖 Android - Google Play Store

#### 1. Build การใช้งาน
```batch
# รัน build script
.\build_android.bat

# หรือรันแบบ manual
flutter build appbundle --release
```

#### 2. ไฟล์ที่ได้
- **APK**: `build\app\outputs\flutter-apk\app-release.apk` (สำหรับทดสอบ)
- **AAB**: `build\app\outputs\bundle\release\app-release.aab` (สำหรับ Play Store)

#### 3. ข้อมูลแอพ
- **Package Name**: `com.rgbcontroller.esp32.app`
- **Version**: 1.0.0 (Version Code: 1)
- **Min SDK**: Android 5.0 (API 21)
- **Target SDK**: Android 14 (API 34)

#### 4. Permissions ที่ขอ
- Internet access (ESP32 communication)
- Network state access
- WiFi state access
- Location access (optional, for WiFi scanning)

### 🍎 iOS - Apple App Store

#### 1. Build การใช้งาน
```batch
# รัน build script (ต้องใช้ macOS + Xcode)
.\build_ios.bat
```

#### 2. Bundle ID
- **iOS Bundle ID**: `com.rgbcontroller.esp32.app`
- **Display Name**: RGB Controller
- **Version**: 1.0.0 (Build: 1)

#### 3. iOS Capabilities
- Local network access
- Background app refresh (optional)

## 📊 App Store Listing Information

### 🎯 App Title และ Description

**English:**
```
Title: RGB Controller - ESP32 LED Strip
Short Description: Control ESP32 RGB LED strips with music reactive mode
Description: 
Professional RGB LED strip controller for ESP32 microcontrollers. Features include:
• Real-time color control with intuitive color picker
• 256 custom pattern steps for complex animations  
• Music reactive mode that syncs LEDs to audio
• Multiple display modes: solid, rainbow, strobe, fade
• WiFi-based WebSocket communication
• Dark theme optimized interface
• Support for WS2812B LED strips up to 300 LEDs

Perfect for home automation, ambient lighting, parties, and creative projects.
Hardware required: ESP32 board, WS2812B LED strip, optional microphone module.
```

**Thai:**
```
Title: RGB Controller - ควบคุมไฟ LED ESP32
Short Description: ควบคุมไฟ LED RGB ESP32 พร้อมโหมดตามจังหวะเพลง
Description:
แอพควบคุมไฟ LED RGB สำหรับไมโครคอนโทรลเลอร์ ESP32 อย่างมืออาชีพ ฟีเจอร์ที่มี:
• ควบคุมสีแบบเรียลไทม์ด้วยเครื่องมือเลือกสีที่ใช้งานง่าย
• ปรับแต่งรูปแบบได้ 256 ขั้นตอนสำหรับแอนิเมชันที่ซับซ้อน
• โหมดตามจังหวะเพลงที่ซิงค์ไฟ LED กับเสียง
• หลายโหมดการแสดงผล: สีเดียว, สีรุ้ง, กะพริบ, เฟด
• การสื่อสารผ่าน WiFi WebSocket
• อินเทอร์เฟซธีมมืดที่ปรับให้เหมาะสม
• รองรับไฟ LED WS2812B ได้สูงสุด 300 ดวง

เหมาะสำหรับระบบบ้านอัจฉริยะ, ไฟแอมเบียนท์, งานปาร์ตี้, และโปรเจกต์สร้างสรรค์
ฮาร์ดแวร์ที่ต้องการ: บอร์ด ESP32, ไฟ LED WS2812B, โมดูลไมโครโฟน (ไม่บังคับ)
```

### 🏷️ Keywords/Tags
- RGB LED
- ESP32 
- IoT
- Smart Home
- LED Strip
- Music Reactive
- WiFi Control
- Home Automation
- Pattern Editor
- WS2812B

### 📱 App Categories
- **Primary**: Utilities
- **Secondary**: Entertainment, Lifestyle

### 🖼️ Screenshots ที่ต้องการ (ขนาดตาม platform)

#### Android (Play Store)
- Phone screenshots: 1080x1920px หรือ 1080x2340px
- Tablet screenshots: 1200x1920px หรือ 2048x2732px
- Feature graphic: 1024x500px

#### iOS (App Store) 
- iPhone screenshots: 1290x2796px (iPhone 14 Pro Max)
- iPad screenshots: 2048x2732px
- App Store preview: 1200x675px

### 🎨 App Icons ที่ต้องการ

#### Android Icons
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72px)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96px)  
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144px)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192px)
- Feature graphic สำหรับ Play Store (1024x500px)

#### iOS Icons
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (หลายขนาด)
- App Store icon (1024x1024px)

## 🔧 ขั้นตอนการ Deploy

### Android Deploy Steps:
1. ✅ สร้าง Google Play Console account
2. ✅ รัน `.\build_android.bat` เพื่อสร้าง AAB file  
3. ✅ Upload AAB ไปยัง Play Console
4. ✅ เพิ่มข้อมูล app listing, screenshots, description
5. ✅ ตั้งค่าราคา (ฟรี หรือ เสียเงิน)
6. ✅ Submit for review

### iOS Deploy Steps:
1. ✅ สร้าง Apple Developer account ($99/year)
2. ✅ ใช้ macOS + Xcode เพื่อ build และ sign
3. ✅ Upload ผ่าน App Store Connect
4. ✅ เพิ่ม app metadata และ screenshots
5. ✅ Submit for App Store review

## 💰 Monetization Options
- **ฟรี**: แอพฟรีพร้อม optional donations
- **เสียเงิน**: $1.99 - $4.99 (ราคาแนะนำ)
- **In-app purchases**: Premium patterns, themes
- **Ads**: Banner หรือ interstitial ads

## 🔒 Privacy Policy
ต้องสร้าง Privacy Policy เพื่อ:
- อธิบายการใช้ network permissions
- การเก็บข้อมูล WiFi settings
- การไม่เก็บข้อมูลส่วนตัว

---
**หมายเหตุ**: ไฟล์ build scripts พร้อมใช้งานใน root directory
- `build_android.bat` - สำหรับ Android
- `build_ios.bat` - สำหรับ iOS (ต้องใช้ macOS)