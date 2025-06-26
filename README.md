# OCR Simple

Aplikasi web sederhana untuk melakukan Optical Character Recognition (OCR) pada gambar menggunakan Go dan Tesseract.

## Fitur

- 🖼️ Upload gambar melalui drag & drop, browse file, atau paste dari clipboard (Ctrl+V)
- 📝 Ekstraksi teks dari gambar menggunakan Tesseract OCR
- 📋 Copy hasil OCR ke clipboard dengan satu klik
- 🎨 Interface web yang responsif dan user-friendly
- ⚡ Optimasi performa untuk pemrosesan cepat
- 🔧 Konfigurasi OCR yang telah dioptimasi untuk akurasi maksimal

## Persyaratan Sistem

### Software yang Diperlukan

1. **Go** (versi 1.23.6 atau lebih baru)
   - Download dari: https://golang.org/dl/

2. **Tesseract OCR**
   - **macOS**: `brew install tesseract`
   - **Ubuntu/Debian**: `sudo apt-get install tesseract-ocr`
   - **Windows**: Download dari https://github.com/UB-Mannheim/tesseract/wiki
   - **CentOS/RHEL**: `sudo yum install tesseract`

3. **Git** (untuk clone repository)

### Dependensi Go

Proyek ini menggunakan dependensi berikut:
- `github.com/otiai10/gosseract/v2 v2.4.1` - Go wrapper untuk Tesseract OCR

## Instalasi

### 1. Clone Repository

```bash
git clone https://github.com/rezapace/Go-ImgToText
cd Reserch-IMG-Todo
```

### 2. Install Tesseract OCR

**macOS:**
```bash
brew install tesseract
```

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install tesseract-ocr
```

**Windows:**
1. Download installer dari https://github.com/UB-Mannheim/tesseract/wiki
2. Install dan pastikan tesseract ada di PATH

### 3. Install Dependensi Go

```bash
go mod download
```

### 4. Build dan Jalankan

```bash
# Build aplikasi
go build -o ocr-app main.go

# Jalankan aplikasi
./ocr-app
```

Atau langsung jalankan tanpa build:

```bash
go run main.go
```

## Penggunaan

1. Jalankan aplikasi dengan perintah di atas
2. Buka browser dan akses `http://localhost:8080`
3. Upload gambar dengan salah satu cara:
   - **Drag & Drop**: Seret gambar ke area upload
   - **Browse**: Klik tombol "Browse" dan pilih file
   - **Paste**: Copy gambar ke clipboard dan tekan Ctrl+V
4. Tunggu proses OCR selesai
5. Hasil teks akan muncul di panel kanan
6. Klik "Copy Text" untuk menyalin hasil ke clipboard

## Format Gambar yang Didukung

- PNG (.png)
- JPEG (.jpg, .jpeg)
- GIF (.gif)
- BMP (.bmp)

## Konfigurasi OCR

Aplikasi ini telah dikonfigurasi dengan pengaturan optimal untuk:
- Kecepatan pemrosesan maksimal
- Akurasi tinggi untuk teks bahasa Inggris
- Pengenalan karakter alfanumerik dan simbol umum

## Struktur Proyek

```
.
├── main.go          # File utama aplikasi
├── go.mod           # Definisi modul Go
├── go.sum           # Checksum dependensi
├── README.md        # Dokumentasi ini
├── Makefile         # Build automation
└── ocr-app/         # Binary hasil build (setelah build)
```

## API Endpoints

- `GET /` - Halaman utama aplikasi
- `POST /upload` - Upload dan proses gambar untuk OCR

## Troubleshooting

### Error: "tesseract not found"
- Pastikan Tesseract sudah terinstall
- Pastikan Tesseract ada di PATH sistem
- Restart terminal/command prompt setelah instalasi

### Error: "failed to set image"
- Pastikan format gambar didukung
- Coba dengan gambar yang lebih kecil (< 3MB)
- Pastikan gambar tidak corrupt

### Hasil OCR tidak akurat
- Gunakan gambar dengan resolusi tinggi
- Pastikan teks dalam gambar jelas dan kontras tinggi
- Hindari gambar dengan background yang kompleks

## Kontribusi

1. Fork repository ini
2. Buat branch fitur baru (`git checkout -b feature/fitur-baru`)
3. Commit perubahan (`git commit -am 'Tambah fitur baru'`)
4. Push ke branch (`git push origin feature/fitur-baru`)
5. Buat Pull Request

## Lisensi

Proyek ini menggunakan lisensi MIT. Lihat file LICENSE untuk detail lengkap.

## Teknologi yang Digunakan

- **Backend**: Go (Golang)
- **OCR Engine**: Tesseract
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **HTTP Server**: Go net/http package

## Performa

- Waktu pemrosesan: ~1-3 detik per gambar (tergantung ukuran)
- Ukuran file maksimal: 3MB
- Concurrent request: Didukung
- Memory usage: Optimized untuk penggunaan minimal