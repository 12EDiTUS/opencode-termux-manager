# 🚀 OpenCode Master Manager (Termux)

A comprehensive, automated management script for installing and updating **OpenCode** on Android via Termux. This tool bridges the gap between official upstream releases and the specialized Android environment.

---

## 🌟 Overview

OpenCode is a powerful tool, but running it on Android/Termux requires specific modifications (like `glibc` integration and `statx` syscall shimming). Traditionally, users had to wait for community-maintained `.deb` packages to catch up with official releases.

**OpenCode Master Manager** changes that. By acting as a **local build engine**, this script empowers you to pull the absolute latest official code from the source and compile a custom, optimized installer directly on your device.

---

## 🛠️ Key Features

- **Local Build Engine:** Compiles the necessary shims and wraps the official binary specifically for your device's architecture.
- **Upstream Real-time Updates:** Automatically detects and fetches the latest version tags from `anomalyco/opencode`.
- **Automatic Dependency Handling:** Installs everything needed—from `glibc` to `patchelf`—without user intervention.
- **Multi-Agent Readiness:** Integrated support for `AGENTS.md` to enable high-level orchestration features.
- **Zero-Waste Policy:** All temporary build artifacts and source folders are purged immediately after installation to keep your storage lean.

---

## 📜 Installation Guide

### Option 1: The Quick Start (Recommended)
Copy and paste this command into your Termux terminal to download and start the manager immediately:

```bash
curl -sL https://raw.githubusercontent.com/[YOUR_GITHUB_USERNAME]/[REPO_NAME]/main/manage_opencode.sh -o manage_opencode.sh && chmod +x manage_opencode.sh && ./manage_opencode.sh
```

### Option 2: Manual Installation
1. Download the `manage_opencode.sh` file.
2. Grant execution permission: `chmod +x manage_opencode.sh`
3. Run the script: `./manage_opencode.sh`

---

## 🔍 How It Works (Detailed Process)

To ensure transparency, here is exactly what the script does during each phase:

1. **Environment Preparation:** The script ensures your Termux environment is up-to-date. It installs essential tools like `make`, `git`, `patchelf`, `binutils`, and `jq`. It also sets up the `glibc-repo`, which is mandatory for running modern Linux binaries on Android.
2. **Upstream Discovery:** Instead of using a hardcoded version, the script queries the official GitHub API of OpenCode to find the latest "Tag Name". This ensures you are never stuck on an old version.
3. **Local Porting & Compilation:** The script clones specialized build tools (referenced from Hope2333). It downloads the official GNU/Linux binary and uses a technique called **Binary Wrapping**. It injects a `statx-shim` to prevent Android from crashing the app due to security restrictions and uses `patchelf` to link the binary to the correct `glibc` libraries within Termux.
4. **Custom Packaging:** Once the binary is patched and ready, the script generates a native `.deb` package specifically for your device.
5. **Deployment & Cleanup:** The generated package is installed via `apt`. Finally, the script triggers a cleanup routine that deletes several hundred megabytes of temporary build source files, leaving only the final, working application.

---

## 🤝 Credits & Acknowledgments

- **Core Porting Logic:** Special thanks to **Hope2333** for the `opencode-termux` build framework and the `bun-termux-loader`. This tool relies on the foundational work done by Hope2333 to bridge the gap between glibc and Android Bionic.
- **Modifications & Management Layer:** The automated "Local Build" strategy, real-time version discovery, and the Master Manager TUI (Terminal User Interface) were developed/modified to ensure users always have access to the absolute latest version without waiting for pre-built packages.

---
---

# 🚀 OpenCode Master Manager (Termux) - ภาษาไทย

สคริปต์จัดการ OpenCode แบบครบวงจรสำหรับการติดตั้งและอัปเดตบน Android ผ่าน Termux เครื่องมือนี้ช่วยแก้ปัญหาช่องว่างระหว่างเวอร์ชันล่าสุดจากผู้พัฒนา (Official Upstream) และสภาพแวดล้อมเฉพาะของ Android

---

## 🌟 ภาพรวม

OpenCode เป็นเครื่องมือที่มีประสิทธิภาพสูง แต่การรันบน Android/Termux จำเป็นต้องมีการปรับแต่งเฉพาะทาง (เช่น การรวม `glibc` และการแก้บั๊ก `statx` syscall) โดยปกติแล้ว ผู้ใช้ต้องรอให้มีผู้ทำแพ็กเกจ `.deb` ออกมาแจกจ่าย ซึ่งมักจะอัปเดตไม่ทันเวอร์ชันล่าสุดจากต้นฉบับ

**OpenCode Master Manager** จึงถูกสร้างมาเพื่อแก้ปัญหานี้ โดยการเปลี่ยนเครื่องของคุณให้เป็น **"เครื่องยนต์สำหรับสร้างแพ็กเกจ" (Local Build Engine)** สคริปต์นี้จะดึงโค้ดล่าสุดจากต้นฉบับมา และทำการคอมไพล์ (Compile) ตัวติดตั้งที่ปรับแต่งมาเพื่อเครื่องของคุณโดยเฉพาะในทันที

---

## 🛠️ คุณสมบัติเด่น

- **Local Build Engine:** สร้างและปรับแต่งไบนารีให้เข้ากับสถาปัตยกรรมของเครื่องคุณโดยตรง
- **Upstream Real-time Updates:** ตรวจสอบและดึงเวอร์ชันล่าสุดจาก `anomalyco/opencode` แบบเรียลไทม์ (ทันทีที่ต้นฉบับอัปเดต)
- **Automatic Dependency Handling:** จัดการ Library ที่จำเป็นทั้งหมดอัตโนมัติ (เช่น `glibc`, `patchelf`, `make`) โดยที่คุณไม่ต้องมีความรู้ด้านเทคนิค
- **Multi-Agent Readiness:** รองรับการใช้งาน `AGENTS.md` เพื่อระบบการทำงานแบบ Agent ขั้นสูงของ OpenCode
- **Zero-Waste Policy:** ระบบจะลบไฟล์ขยะและซอร์สโค้ดชั่วคราวทิ้งทันทีหลังติดตั้งเสร็จ เพื่อประหยัดพื้นที่จัดเก็บข้อมูลในมือถือ

---

## 📜 วิธีติดตั้งและใช้งาน

### วิธีที่ 1: ติดตั้งแบบรวดเร็ว (แนะนำ)
คัดลอกคำสั่งด้านล่างไปวางใน Termux เพื่อดาวน์โหลดและเริ่มใช้งานทันที:

```bash
curl -sL https://raw.githubusercontent.com/[YOUR_GITHUB_USERNAME]/[REPO_NAME]/main/manage_opencode.sh -o manage_opencode.sh && chmod +x manage_opencode.sh && ./manage_opencode.sh
```

### วิธีที่ 2: ติดตั้งด้วยตัวเอง
1. ดาวน์โหลดไฟล์ `manage_opencode.sh` มาไว้ในเครื่อง
2. ให้สิทธิ์การรันไฟล์: `chmod +x manage_opencode.sh`
3. เริ่มรันสคริปต์: `./manage_opencode.sh`

---

## 🔍 ขั้นตอนการทำงานโดยละเอียด (โปร่งใส)

เพื่อให้เกิดความโปร่งใสและมั่นใจในความปลอดภัย นี่คือสิ่งที่สคริปต์ทำในแต่ละขั้นตอน:

1.  **การเตรียมสภาพแวดล้อม:** สคริปต์จะตรวจสอบความพร้อมของ Termux และติดตั้งเครื่องมือที่จำเป็น เช่น `make`, `git`, `patchelf`, `binutils` และ `jq` รวมถึงตั้งค่า `glibc-repo` ซึ่งเป็นหัวใจสำคัญในการรันโปรแกรม Linux บน Android
2.  **การค้นหาเวอร์ชันล่าสุด:** สคริปต์จะสอบถามไปยัง GitHub API ของ OpenCode เพื่อหาเวอร์ชันล่าสุด (Tag Name) เสมอ ทำให้คุณไม่ได้ของเก่าค้างสต็อก
3.  **การแปลงไฟล์และคอมไพล์:** นี่คือหัวใจสำคัญ สคริปต์จะโคลนเครื่องมือพิเศษมา และทำการ **"Binary Wrapping"** โดยการใส่ `statx-shim` เพื่อป้องกันแอปเด้งเนื่องจากข้อจำกัดความปลอดภัยของ Android และใช้ `patchelf` เพื่อเชื่อมโยงโปรแกรมเข้ากับ Library ของ Termux ให้ถูกต้อง
4.  **การสร้างแพ็กเกจ:** เมื่อปรับแต่งเสร็จ ระบบจะแพ็กทุกอย่างเป็นไฟล์ `.deb` ที่ออกแบบมาเพื่อเครื่องของคุณโดยเฉพาะ
5.  **การติดตั้งและล้างข้อมูล:** ระบบจะติดตั้งไฟล์ `.deb` ผ่าน `apt` และทำลายซอร์สโค้ดชั่วคราวที่มีขนาดใหญ่ทิ้งทันที เหลือไว้เพียงตัวแอปที่ใช้งานได้จริง เพื่อให้เครื่องของคุณสะอาดและมีพื้นที่เหลือ

---

## 🤝 เครดิตและผู้จัดทำ

- **Logic การพอร์ตหลัก (Core Logic):** ขอขอบคุณ **Hope2333** สำหรับเฟรมเวิร์กสร้าง `opencode-termux` และ `bun-termux-loader` เครื่องมือนี้อาศัยพื้นฐานอันยอดเยี่ยมที่คุณ Hope2333 วางไว้เพื่อให้โปรแกรมทำงานได้บน Android
- **การพัฒนาส่วนต่อขยาย (Modifications):** ระบบ "Local Build" อัตโนมัติ, การตรวจจับเวอร์ชันแบบเรียลไทม์ และเมนูสั่งการ (TUI) ได้รับการพัฒนาและปรับแต่งเพิ่มเติมเพื่อให้ผู้ใช้งานทั่วไปสามารถเข้าถึงเวอร์ชันล่าสุดได้ง่ายที่สุดโดยไม่ต้องรอคนอื่นทำไฟล์ให้

---
*จัดทำขึ้นเพื่อให้การใช้งาน OpenCode บน Termux สะดวก รวดเร็ว และทันสมัยที่สุด*
