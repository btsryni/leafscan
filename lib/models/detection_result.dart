import 'dart:math';

/// Data model representing a coffee leaf disease detection result.
class DetectionResult {
  final String id;
  final String diseaseName;
  final String diseaseType; // 'Virus', 'Hama', 'Jamur', 'Sehat'
  final double confidence; // 0.0 to 100.0
  final String imageUrl;
  final String gejala;
  final String penyebab;
  final String caraPencegahan;
  final DateTime date;
  final bool isLocalFile;

  DetectionResult({
    required this.id,
    required this.diseaseName,
    required this.diseaseType,
    required this.confidence,
    required this.imageUrl,
    required this.gejala,
    required this.penyebab,
    required this.caraPencegahan,
    required this.date,
    this.isLocalFile = false,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      id: json['id'] as String,
      diseaseName: json['diseaseName'] as String,
      diseaseType: json['diseaseType'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      gejala: json['gejala'] as String,
      penyebab: json['penyebab'] as String,
      caraPencegahan: json['caraPencegahan'] as String,
      date: DateTime.parse(json['date'] as String),
      isLocalFile: json['isLocalFile'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diseaseName': diseaseName,
      'diseaseType': diseaseType,
      'confidence': confidence,
      'imageUrl': imageUrl,
      'gejala': gejala,
      'penyebab': penyebab,
      'caraPencegahan': caraPencegahan,
      'date': date.toIso8601String(),
      'isLocalFile': isLocalFile,
    };
  }

  /// High-quality mock data templates for coffee leaf disease diagnostics,
  /// mapped to local assets in assets/placeholder/
  static final List<DetectionResult> staticSamples = [
    DetectionResult(
      id: 'sample_karat_daun',
      diseaseName: 'Karat Daun',
      diseaseType: 'Jamur',
      confidence: 92.5,
      imageUrl: 'assets/placeholder/Asset Karat daun.png',
      gejala: 'Ditandai dengan munculnya bercak-bercak kuning jingga seperti serbuk halus (spora) di sisi bawah permukaan daun kopi. Bercak tersebut lambat laun melebar, menyebabkan daun menguning, layu, kering, hingga akhirnya berguguran secara massal.',
      penyebab: 'Disebabkan oleh infeksi jamur patogen karat Hemileia vastatrix. Jamur ini menyukai lingkungan hangat dengan kelembaban tinggi dan menyebar dengan sangat cepat melalui tiupan angin maupun percikan air hujan.',
      caraPencegahan: 'Tanam varietas kopi unggul yang tahan penyakit karat (misal: Lini S). Lakukan pemangkasan tajuk secara teratur agar sirkulasi udara lancar dan sinar matahari masuk. Semprotkan fungisida kontak berbahan aktif tembaga secara berkala saat musim hujan.',
      date: DateTime.now().subtract(const Duration(days: 10)),
    ),
    DetectionResult(
      id: 'sample_bercak_daun',
      diseaseName: 'Bercak Daun',
      diseaseType: 'Jamur',
      confidence: 88.4,
      imageUrl: 'assets/placeholder/Asset Bercak daun.png',
      gejala: 'Terdapat bercak-bercak bulat kecil berwarna coklat gelap kemerahan hingga coklat tua yang berbatas tegas dengan pola lingkaran konsentris menyerupai mata coklat (brown eye spots) pada permukaan daun kopi.',
      penyebab: 'Disebabkan oleh serangan jamur Cercospora coffeicola. Biasanya menyebar pada perkebunan kopi yang kurang terawat, terlalu rapat jarak tanamnya, atau mengalami defisiensi unsur hara makro (terutama Nitrogen).',
      caraPencegahan: 'Aplikasikan pemupukan seimbang (NPK) untuk memperkuat daya tahan jaringan tanaman. Atur jarak tanam ideal dan bersihkan rumput/gulma yang menjadi inang sekunder. Apabila terjadi infeksi berat, semprotkan fungisida sistemik golongan triazol.',
      date: DateTime.now().subtract(const Duration(days: 15)),
    ),
    DetectionResult(
      id: 'sample_embun_jelaga',
      diseaseName: 'Embun Jelaga',
      diseaseType: 'Hama',
      confidence: 85.0,
      imageUrl: 'assets/placeholder/Asset Embun Jelaga.png',
      gejala: 'Terbentuknya lapisan tipis atau selaput hitam pekat seperti abu jelaga/arang yang menyelimuti permukaan atas atau bawah daun kopi. Lapisan ini lengket dan menghalangi masuknya sinar matahari untuk fotosintesis.',
      penyebab: 'Disebabkan oleh kolonisasi jamur Capnodium coffeae. Jamur saprofit ini tidak parasit langsung pada daun, melainkan tumbuh subur di atas sekresi cairan manis (embun madu) yang dikeluarkan oleh kutu daun (aphid) atau kutu perisai.',
      caraPencegahan: 'Kendalikan serangga vektor (kutu daun/semut pembawa) terlebih dahulu menggunakan insektisida organik berbasis minyak mimba (neem oil). Bersihkan lapisan jelaga hitam menggunakan semprotan air bersih atau air sabun ringan.',
      date: DateTime.now().subtract(const Duration(days: 20)),
    ),
    DetectionResult(
      id: 'sample_penggorok_daun',
      diseaseName: 'Penggorok Daun',
      diseaseType: 'Hama',
      confidence: 95.8,
      imageUrl: 'assets/placeholder/Asset Penggorok Daun.png',
      gejala: 'Daun kopi berlubang-lubang kecil or memiliki corak alur berkelok terowongan putih/keperakan tipis di bagian epidermis daun yang lama kelamaan mengering dan berubah menjadi bercak kecoklatan lebar tak beraturan.',
      penyebab: 'Disebabkan oleh larva serangga ngengat kecil Leucoptera coffeella. Larva tersebut masuk ke dalam jaringan daun (mesofil) dan memakan nutrisi dari dalam daun, meninggalkan rongga kosong berongga.',
      caraPencegahan: 'Lakukan sanitasi kebun dengan mengumpulkan dan membakar daun-daun gugur yang terinfeksi larva. Manfaatkan musuh alami (tawon parasitoid) untuk menekan populasi ngengat. Jika kritis, gunakan insektisida sistemik berbahan aktif imidakloprid.',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    DetectionResult(
      id: 'sample_hawar_daun',
      diseaseName: 'Hawar Daun',
      diseaseType: 'Jamur',
      confidence: 90.1,
      imageUrl: 'assets/placeholder/Asset Penggorok Daun-1.png',
      gejala: 'Ujung atau tepi daun kopi mengalami perubahan warna menjadi coklat tua kering seperti terbakar, yang menjalar dengan cepat ke seluruh helai daun hingga gugur berjatuhan.',
      penyebab: 'Disebabkan oleh serangan patogen jamur Rhizoctonia solani atau bakteri Pseudomonas. Sangat aktif saat musim hujan dengan kelembaban ekstrem.',
      caraPencegahan: 'Jaga drainase tanah agar tidak tergenang, lakukan sanitasi dengan membakar daun terinfeksi, dan gunakan fungisida sistemik berbahan aktif benomil secara preventif.',
      date: DateTime.now().subtract(const Duration(days: 25)),
    ),
    DetectionResult(
      id: 'sample_tungau_merah',
      diseaseName: 'Tungau Laba-laba Merah',
      diseaseType: 'Hama',
      confidence: 87.5,
      imageUrl: 'assets/placeholder/Asset Tungau.png',
      gejala: 'Munculnya bintik-bintik halus berwarna kelabu kekuningan di permukaan daun yang kemudian meluas menjadi bercak perunggu kusam. Seringkali terdapat jaring-jaring benang sutra sangat halus di bagian bawah daun kopi.',
      penyebab: 'Disebabkan oleh tungau laba-laba merah Oligonychus coffeae. Serangan tungau ini melonjak tajam saat musim kemarau panjang yang kering dan panas, menghancurkan sel klorofil daun.',
      caraPencegahan: 'Jaga kelembaban tanah perkebunan dengan mulsa organik. Semprotkan air di atas tajuk pohon kopi pada sore hari saat kemarau untuk mengusir tungau. Jika terjadi ledakan populasi, gunakan akarisida berbahan aktif abamektin.',
      date: DateTime.now().subtract(const Duration(days: 30)),
    ),
    DetectionResult(
      id: 'sample_sehat',
      diseaseName: 'Daun Sehat',
      diseaseType: 'Sehat',
      confidence: 99.4,
      imageUrl: 'assets/placeholder/Asset daun sehat.png',
      gejala: 'Daun kopi berwarna hijau segar mengkilap sempurna, memiliki tekstur kenyal dan kokoh, tidak terdapat noda bercak, lubang terowongan, ataupun lapisan hitam. Tulang daun terlihat bersih dan simetris.',
      penyebab: 'Kondisi daun kopi sehat karena mendapatkan asupan hara makro dan mikro yang cukup, pasokan air seimbang, sirkulasi udara optimal, serta perlindungan kebun yang terawat dengan baik.',
      caraPencegahan: 'Pertahankan teknik budidaya kopi yang baik (Good Agricultural Practices). Lakukan pemangkasan pemeliharaan secara rutin, pemupukan organik/kimia berimbang sesuai dosis rekomendasi, serta monitoring berkala kesehatan kebun.',
      date: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  /// Factory constructor to map predicted label outputs into fully detailed DetectionResult cards
  factory DetectionResult.fromClassification({
    required String detectedLabel,
    required double confidence,
    required String customImagePath,
    bool isLocalFile = true,
  }) {
    final template = staticSamples.firstWhere(
      (item) => item.diseaseName.toLowerCase() == detectedLabel.toLowerCase(),
      orElse: () => staticSamples.firstWhere((item) => item.diseaseName == 'Daun Sehat'),
    );

    return DetectionResult(
      id: 'result_${DateTime.now().millisecondsSinceEpoch}',
      diseaseName: template.diseaseName,
      diseaseType: template.diseaseType,
      confidence: confidence,
      imageUrl: customImagePath,
      gejala: template.gejala,
      penyebab: template.penyebab,
      caraPencegahan: template.caraPencegahan,
      date: DateTime.now(),
      isLocalFile: isLocalFile,
    );
  }

  static DetectionResult getMockDetection(String query) {
    final lower = query.toLowerCase();
    for (final sample in staticSamples) {
      if (sample.diseaseName.toLowerCase().contains(lower)) {
        return DetectionResult(
          id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
          diseaseName: sample.diseaseName,
          diseaseType: sample.diseaseType,
          confidence: 85.0 + Random().nextDouble() * 14.0,
          imageUrl: sample.imageUrl,
          gejala: sample.gejala,
          penyebab: sample.penyebab,
          caraPencegahan: sample.caraPencegahan,
          date: DateTime.now(),
        );
      }
    }
    // Default fallback
    final randomSample = staticSamples[Random().nextInt(staticSamples.length)];
    return DetectionResult(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      diseaseName: randomSample.diseaseName,
      diseaseType: randomSample.diseaseType,
      confidence: 80.0 + Random().nextDouble() * 19.0,
      imageUrl: randomSample.imageUrl,
      gejala: randomSample.gejala,
      penyebab: randomSample.penyebab,
      caraPencegahan: randomSample.caraPencegahan,
      date: DateTime.now(),
    );
  }
}
