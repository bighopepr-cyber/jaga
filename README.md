🛡️ Sistem Absensi Keluar & Kembali (Modular Security Platform)

📌 Overview

Sistem ini dirancang untuk memantau pergerakan anggota satuan secara aman, disiplin, fleksibel, dan auditable.

Menggunakan pendekatan QR statis + token dinamis + modular security system, sistem ini memungkinkan pos jaga / petugas untuk mengontrol tingkat keamanan sesuai kebutuhan operasional lapangan.

Sistem ini disesuaikan untuk lingkungan militer / semi-militer dengan fokus pada:

- Disiplin tinggi
- Validasi kehadiran yang ketat
- Audit penuh untuk komando

---

🚀 Key Features

🔳 QR-Based Attendance

- 2 QR statis: Keluar & Kembali
- Token dinamis untuk mencegah penyalahgunaan

🔐 Modular Security System

Semua fitur keamanan dapat diatur oleh petugas melalui dashboard pos jaga.

📍 Location Validation

- GPS
- WiFi SSID
- (Opsional) Bluetooth Beacon
- Radius geofencing configurable

📱 Device Binding

- Kontrol perangkat anggota
- Mode: OFF / SOFT / STRICT

📸 Proof of Presence

- Snapshot kamera saat absensi
- Mode: OPTIONAL / REQUIRED

🧠 Smart Detection

- Deteksi anomali aktivitas
- Fake GPS
- Device switching
- Scan tidak wajar

📊 Audit & Monitoring

- Log lengkap (NRP, device, IP, lokasi)
- Monitoring real-time
- Status anggota (keluar / kembali)

⚙️ Installer 1-Click

- Setup cepat untuk deployment di pos jaga

---

🆕 📥 Mass Input Data Anggota (Bulk Import)

Untuk kebutuhan satuan (kompi/batalyon), sistem mendukung input data anggota secara massal melalui dashboard admin.

📄 Format File yang Didukung

- ".csv"
- ".xlsx"

🧾 Struktur Data (Wajib)

Field| Keterangan
nrp| Nomor Registrasi Prajurit (unik)
nama| Nama anggota
pangkat| Pangkat
satuan| Unit / kompi
pin| PIN awal
status| aktif / nonaktif

---

⚙️ Fitur Import

- Upload file langsung dari dashboard
- Validasi otomatis:
  - NRP duplikat
  - Format data salah
- Preview sebelum submit
- Auto-generate PIN (opsional)
- Update data massal (overwrite / skip)

---

🔒 Keamanan Import

- Hanya dapat diakses oleh petugas berwenang
- Log aktivitas import dicatat (audit trail)
- Setiap perubahan data anggota tersimpan

---

🖥️ Admin Dashboard (Pos Jaga)

Dashboard dirancang untuk kebutuhan operasional militer, cepat, jelas, dan minim distraksi.

---

📊 Statistik Operasional (Real-Time)

Dashboard menampilkan statistik berikut:

🪖 Status Anggota

- Total anggota aktif
- Jumlah anggota:
  - 🟢 Di dalam markas
  - 🔵 Sedang keluar
  - 🔴 Terlambat kembali

---

⏱️ Aktivitas Harian

- Total keluar hari ini
- Total kembali hari ini
- Peak hour aktivitas

---

⚠️ Keamanan & Anomali

- Jumlah aktivitas mencurigakan
- Fake GPS terdeteksi
- Device tidak dikenal
- Scan di luar radius

---

📍 Monitoring Lokasi

- Distribusi lokasi anggota (opsional map)
- Highlight anggota di luar zona

---

📈 Tren

- Grafik aktivitas harian / mingguan
- Pola keluar-masuk satuan

---

🔧 Security Control Panel

Petugas dapat mengatur:

- Tingkat keamanan
- Aktivasi modul
- Parameter sistem

---

🎯 Preset Mode

Mode| Deskripsi
🟢 LOW| Operasional ringan
🟡 MEDIUM| Standar
🔴 HIGH| Disiplin tinggi (direkomendasikan)

---

🧩 Modular Feature Toggle System

Module| Mode
Authentication| PIN / OTP / Face
Device Binding| OFF / SOFT / STRICT
Location| OFF / GPS / HYBRID
QR Security| Configurable
Presence| OFF / OPTIONAL / REQUIRED
Detection| LOW / MEDIUM / HIGH
Audit| ON / OFF

---

🔄 System Flow

📤 Keluar

1. Scan QR Keluar
2. Validasi token
3. Login anggota
4. Validasi device
5. Validasi lokasi
6. Capture bukti (jika aktif)
7. Analisis sistem
8. Submit → status keluar tercatat

---

📥 Kembali

Flow identik dengan update status kembali.

---

🔒 Security Features

Risiko| Mitigasi
Penyalahgunaan QR| Token dinamis
Fake GPS| Hybrid validation
PIN sharing| Device binding
Manipulasi waktu| Server timestamp
Aktivitas mencurigakan| Smart detection

---

🏗️ System Architecture

Backend

- Token engine
- Validation engine
- Smart detection
- Config system

Frontend

- PWA scan QR
- Dashboard admin (pos jaga)

Database

- Data anggota
- Log aktivitas
- Konfigurasi sistem

---

⚙️ Configuration Example

{
  "device_mode": "strict",
  "geo_mode": "hybrid",
  "qr_refresh": 10,
  "face_required": true,
  "detection_level": "high"
}

---

📦 Installation

1. Jalankan installer
2. Setup koordinat pos
3. Atur radius & token
4. Import data anggota (bulk)
5. Sistem siap digunakan

---

📝 Operational Notes (Militer)

- QR ditempatkan di pos jaga resmi
- Absensi wajib dilakukan secara langsung (tidak boleh diwakilkan)
- Setiap aktivitas tercatat untuk kebutuhan audit komando
- Data anggota harus diperbarui secara berkala

---

💡 Use Cases

- Satuan militer
- Pengamanan objek vital
- Operasi lapangan
- Latihan militer

---

🚀 Roadmap

- Integrasi biometrik lanjutan
- Offline mode (operasi lapangan)
- Integrasi sistem komando
- AI behavior analysis

---

🛡️ Value Proposition

- Disiplin & kontrol tinggi
- Transparansi operasional
- Konfigurasi fleksibel
- Siap deployment lapangan

---

📄 License

Custom Military / Enterprise License

---

👨‍💻 Author

Dirancang untuk mendukung operasional satuan dengan standar disiplin tinggi, keamanan, dan akuntabilitas penuh.
