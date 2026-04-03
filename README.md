🛡️ Sistem Absensi Keluar & Kembali (Modular Security Platform)

📌 Overview

Sistem ini dirancang untuk memantau pergerakan anggota (keluar & kembali) secara aman, fleksibel, dan auditable.

Menggunakan pendekatan QR statis + token dinamis + modular security system, sistem ini memungkinkan admin (pos jaga) untuk mengatur tingkat keamanan sesuai kebutuhan operasional melalui dashboard.

---

🚀 Key Features

🔳 QR-Based Attendance

- 2 QR statis: Keluar & Kembali
- Token dinamis untuk mencegah replay & penyalahgunaan

🔐 Modular Security System

Semua fitur keamanan dapat diaktifkan / dinonaktifkan melalui dashboard admin.

📍 Location Validation

- GPS
- WiFi SSID
- (Opsional) Bluetooth Beacon
- Geofencing radius configurable

📱 Device Binding

- Mengikat akun ke device tertentu
- Mode: OFF / SOFT / STRICT

📸 Proof of Presence

- Snapshot kamera saat absensi
- Mode: OPTIONAL / REQUIRED

🧠 Smart Detection

- Fake GPS detection
- Device switching detection
- Rapid scan detection
- Location anomaly detection

📊 Audit & Monitoring

- Real-time dashboard
- Log lengkap (device, IP, lokasi)
- Status anggota (keluar / kembali)

⚙️ Installer 1-Click

- Setup backend, frontend, dan database otomatis
- GUI konfigurasi awal

---

🧩 Modular Feature Toggle System

Semua fitur dikontrol melalui konfigurasi sistem:

Module| Description| Mode
Authentication| Login & verifikasi| PIN / OTP / Face
Device Binding| Kontrol device| OFF / SOFT / STRICT
Location Validation| Validasi lokasi| OFF / GPS / HYBRID
QR Security| Token QR| Interval & expiry
Proof of Presence| Kamera| OFF / OPTIONAL / REQUIRED
Smart Detection| Deteksi anomali| LOW / MEDIUM / HIGH
Audit System| Logging & monitoring| ON / OFF

---

🖥️ Admin Dashboard

🔧 Security Control Panel

Admin dapat mengatur seluruh sistem secara real-time:

- Enable / disable fitur
- Atur level keamanan
- Monitor aktivitas anggota
- Review alert & anomaly

🎯 Preset Mode

Mode| Deskripsi
🟢 LOW| Basic GPS, QR lambat
🟡 MEDIUM| GPS + WiFi, device soft
🔴 HIGH| Full security (recommended)

---

🔄 System Flow

📤 Keluar

1. Scan QR Keluar
2. Validasi token
3. Login (NRP + PIN)
4. Device validation (jika aktif)
5. Location validation (jika aktif)
6. Face capture (jika aktif)
7. Smart detection check
8. Submit → update status & log

📥 Kembali

Flow sama seperti keluar, dengan update status kembali.

---

🔒 Security Features

Risiko| Mitigasi
QR disalahgunakan| Token dinamis + expiry
Fake GPS| Hybrid location + detection
PIN sharing| Device binding
Manipulasi waktu| Server timestamp
Scan dari luar lokasi| Geofencing + validation
Aktivitas mencurigakan| Smart detection

---

🏗️ System Architecture

Backend

- Token management
- Location validation
- Device validation
- Smart detection engine
- API service

Frontend

- QR scanning interface (PWA)
- Login & form
- Admin dashboard

Database

- User (NRP, PIN, device)
- Activity log
- System config
- Audit trail

Realtime Layer

- WebSocket / polling untuk update dashboard & QR

---

⚙️ Configuration Example

{
  "auth": {
    "pin": true,
    "otp": false,
    "face": true
  },
  "device": {
    "mode": "strict"
  },
  "geo": {
    "mode": "hybrid",
    "radius": 50
  },
  "qr": {
    "refresh_interval": 10,
    "anti_replay": true
  },
  "presence": {
    "face_required": true
  },
  "detection": {
    "level": "high",
    "action": "block"
  }
}

---

📦 Installation

1. Jalankan Installer

- Pilih platform (Windows/Linux/Mac)
- Jalankan installer 1-klik

2. Setup Awal

- Input koordinat pos jaga
- Tentukan radius geofencing
- Atur interval QR token
- Pilih lokasi database

3. Jalankan Sistem

- Backend, frontend, dan database otomatis aktif

---

📝 Operational Notes

- QR tidak perlu diganti (token berubah otomatis)
- GPS disarankan aktif untuk akurasi tinggi
- Backup database secara berkala
- Admin dapat mengubah konfigurasi kapan saja

---

💡 Use Cases

- Militer / keamanan
- Satpam perusahaan
- Pabrik & industri
- Kampus
- Event management

---

🚀 Roadmap (Optional Development)

- Mobile native app
- Integrasi WhatsApp / Email notifikasi
- Biometric authentication
- Offline sync mode
- AI anomaly detection advanced

---

🛡️ Value Proposition

- 🔒 Security configurable (rare feature)
- ⚙️ Fleksibel untuk berbagai kondisi lapangan
- 📦 Mudah deploy (installer 1-klik)
- 📊 Full audit & accountability

---

📄 License

MIT License / Custom Enterprise License (opsional)

---

👨‍💻 Author

Developed as a modular, scalable, and secure attendance system for high-discipline environments.
