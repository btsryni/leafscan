# Implementasi Metode Convolutional Neural Network (CNN) Untuk Deteksi Penyakit Daun Kopi Pada Aplikasi Mobile

Aplikasi mobile berbasis Android untuk mendeteksi penyakit daun tanaman kopi secara offline (*on-device inference*) dengan mendukung perbandingan performa antara tiga arsitektur CNN terkemuka (MobileNetV2, ResNet50, dan Xception).

---

## 👨‍🎓 Identitas Mahasiswa
*   **Nama Mahasiswa:** Beta Suryani
*   **Kampus:** Politeknik Negeri Sriwijaya
*   **Jurusan:** Teknik Komputer

---

## 📝 Deskripsi Singkat Project
**LeafScan Kopi** adalah aplikasi mobile berbasis Android yang dirancang untuk mengidentifikasi dan mengklasifikasikan 7 jenis kondisi/penyakit pada daun tanaman kopi secara instan.

Aplikasi ini memiliki arsitektur *multi-model* fleksibel yang ditujukan untuk penelitian perbandingan performa kecerdasan buatan (*Deep Learning*) langsung di perangkat mobile. Melalui konfigurasi konstanta tingkat kompilasi, aplikasi dapat dirilis menggunakan salah satu dari tiga model CNN yang dilatih (MobileNetV2, ResNet50, atau Xception). Proses inferensi dijalankan sepenuhnya secara luring (*offline*) demi kecepatan deteksi yang maksimal.

---

## 🧠 Model yang Digunakan
Aplikasi ini mendukung tiga arsitektur Convolutional Neural Network (CNN) terkemuka dalam format TensorFlow Lite (TFLite) terkompresi yang siap pakai:
*   **Pilihan Arsitektur Model (Bisa Diatur Lewat Konfigurasi Kompilasi):**
    1.  **MobileNetV2** (`best_MobileNetV2_Beta.tflite`) - Model berukuran ringan ($\approx 2.8$ MB) yang dioptimalkan untuk performa tinggi pada perangkat seluler.
    2.  **ResNet50** (`best_ResNet50_Beta.tflite`) - Model dengan arsitektur mendalam berbasis koneksi sisa ($\approx 24.4$ MB) untuk ekstraksi fitur yang kompleks.
    3.  **Xception** (`best_Xception_Beta.tflite`) - Model dengan arsitektur *Depthwise Separable Convolution* tingkat lanjut ($\approx 22.0$ MB) untuk performa klasifikasi yang presisi.
*   **Jumlah Kelas Klasifikasi:** 7 Kelas patologis/kondisi daun tanaman kopi:
    1.  `Bercak Daun` (Cercospora coffeicola)
    2.  `Daun Sehat` (Healthy leaf)
    3.  `Embun Jelaga` (Sooty mold)
    4.  `Hawar Daun` (Leaf blight)
    5.  `Karat Daun` (Hemileia vastatrix)
    6.  `Penggorok Daun` (Coffee leaf miner)
    7.  `Tungau Laba-laba Merah` (Red spider mites)

---

## 📐 Metode Rescale yang Digunakan
Sebelum citra daun dimasukkan ke model untuk dilakukan inferensi, gambar melalui tahapan pra-pemrosesan berikut:
1.  **Center Cropping**: Gambar dipotong secara persegi simetris (1:1) berdasarkan dimensi terpendek untuk menghindari distorsi/penyusutan gambar (squishing).
2.  **Resizing**: Gambar persegi diubah dimensinya menjadi ukuran target input model yaitu **$224 \times 224$ piksel**.
3.  **Model-Specific Scalers (Pra-pemrosesan Warna)**:
    *   **MobileNetV2 & Xception**: Nilai piksel diurutkan dalam format **RGB** dan dinormalisasi secara sekuensial ke rentang **`[-1.0, 1.0]`** (sesuai standar `preprocess_input` Keras) menggunakan formula:
        $$f(\text{pixel}) = \frac{\text{pixel} - 127.5}{127.5}$$
    *   **ResNet50**: Nilai piksel diurutkan dalam format **BGR** (Blue, Green, Red) dengan menerapkan pengurangan rata-rata warna ImageNet (*ImageNet mean subtraction*) tanpa pembagian:
        *   Saluran Biru (Blue) = $\text{pixel.b} - 103.939$
        *   Saluran Hijau (Green) = $\text{pixel.g} - 116.779$
        *   Saluran Merah (Red) = $\text{pixel.r} - 123.680$

---

## 📚 Library yang Digunakan
Aplikasi ini dikembangkan menggunakan framework **Flutter** dan dependensi berikut:
*   `tflite_flutter` (v0.12.1): Pustaka driver utama untuk memuat dan mengeksekusi inferensi model TFLite secara lokal di Android.
*   `image` (v4.8.0): Library pemrosesan citra digital untuk operasi pemotongan simetris (center crop), resizing, decoding, dan manipulasi piksel warna.
*   `image_picker` (v1.2.2): Menjembatani akses hardware kamera ponsel atau galeri gambar perangkat lokal Android.
*   `shared_preferences` (v2.5.5): Digunakan sebagai basis data lokal sederhana untuk menyimpan riwayat hasil identifikasi penyakit tanaman kopi secara aman.
*   `google_fonts` (v6.2.1): Mengintegrasikan tipografi premium Google Poppins secara merata ke seluruh elemen teks antarmuka (UI).

---

## 📁 Struktur Folder Project Flutter
Direktori project diatur secara terstruktur demi kemudahan pemeliharaan dan skalabilitas kode:
```text
beta_project/
├── assets/
│   ├── logo/                # Aset logo LeafScan (logo.png & logo-app.png)
│   └── tflite/              # File model TFLite (MobileNetV2, ResNet50, & Xception)
├── lib/
│   ├── screens/             # UI Halaman Aplikasi (Home, Scan, History, About, MainShell)
│   ├── services/            # Logika Bisnis (TFLite Service & Local History DB)
│   │   ├── history_service.dart
│   │   └── tflite_service.dart
│   ├── theme/               # Pengaturan tema visual hijau botani dan typography Poppins
│   ├── widgets/             # Komponen UI modular yang dapat digunakan kembali
│   └── main.dart            # Inisialisasi awal aplikasi
└── pubspec.yaml             # Manajemen pustaka, aset model, dan konfigurasi launcher icon
```

---

## ⚙️ Penjelasan Singkat Kode dan Fungsi Aplikasi
1.  **`main.dart`**: Titik masuk utama aplikasi yang memuat pengaturan rute, inisialisasi tema berbasis fon Poppins, dan peluncuran widget navigasi utama.
2.  **`tflite_service.dart`**:
    *   Membaca konstanta switch `activeModel` (bertipe `ModelType` dengan nilai: `mobileNetV2`, `resNet50`, atau `xception`) untuk memuat model `.tflite` yang sesuai dari aset.
    *   Melakukan manipulasi citra masukan (center crop dan resizing $224 \times 224$ piksel).
    *   Mengalokasikan citra ke bentuk tensor array 4-dimensi `[1, 224, 224, 3]`.
    *   Menerapkan fungsi pra-pemrosesan saluran warna yang presisi (normalisasi RGB `[-1.0, 1.0]` untuk MobileNetV2 dan Xception, sedangkan ResNet50 menggunakan transformasi BGR pengurangan rata-rata warna ImageNet).
    *   Menjalankan inferensi dan mengembalikan label penyakit kopi beserta persentase tingkat kepercayaan (*confidence score*).
3.  **`history_service.dart`**: Mengelola basis data lokal sederhana dengan fungsi menyimpan, mengambil, dan menghapus riwayat pemindaian penyakit tanaman kopi pengguna dengan serialisasi JSON di atas penyimpan lokal `SharedPreferences`.
4.  **`main_shell.dart` (Navigasi & Sinkronisasi Tab)**:
    *   Menggunakan `GlobalKey<HistoryScreenState>` untuk mendeteksi kapan pengguna beralih ke tab Riwayat. Begitu tab Riwayat dibuka, antarmuka akan **langsung dimuat ulang secara otomatis (real-time)** untuk menampilkan item yang baru saja ditambahkan/difavoritkan.
5.  **`history_screen.dart` (Empty-State Pull to Refresh)**:
    *   Menerapkan widget `SingleChildScrollView` dibungkus `LayoutBuilder` dengan parameter `AlwaysScrollableScrollPhysics`. Desain ini memungkinkan pengguna untuk melakukan gerakan tarikan layar kebawah (*fling/pull-to-refresh*) pada halaman riwayat sekalipun database riwayat dalam kondisi kosong (tanpa data).
    *   Menyediakan tombol "Favorit" dengan simbol hati (love) di halaman hasil analisis untuk menandai riwayat penting yang otomatis masuk ke tab histori lokal.
