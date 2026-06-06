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
      gejala: 'Ditandai dengan bercak kuning yang berubah menjadi coklat. Pada permukaan bawah daun muncul noda berwarna kuning hingga jingga. Daun yang terinfeksi akan mengering dan gugur.',
      penyebab: 'Disebabkan oleh jamur Hemileia vastatrix yang berkembang pada kondisi lembap dan curah hujan tinggi. Penyebaran terjadi melalui air hujan, serangga, dan angin.',
      caraPencegahan: '• Menggunakan varietas tahan karat daun, seperti klon S795 dan USDA762.\n• Menerapkan kultur teknis berupa penyiangan, pemupukan, pemangkasan, dan pengelolaan naungan.\n• Menggunakan fungisida nabati, seperti ekstrak biji mahoni konsentrasi 0,1–0,2%, yang efektif menekan penyakit karat daun.\n• Fungisida berbahan aktif tembaga, seperti Nordox, Kocide, Cupravit, dan Dhitane, diaplikasikan dengan konsentrasi 0,3% setiap 2 minggu. Fungisida berbahan aktif triadimefon, seperti Bayleton, Anvil, dan Tilt, diaplikasikan dengan konsentrasi 0,1% sebanyak 1–2 kali aplikasi.',
      date: DateTime.now().subtract(const Duration(days: 10)),
    ),
    DetectionResult(
      id: 'sample_bercak_daun',
      diseaseName: 'Bercak Daun',
      diseaseType: 'Jamur',
      confidence: 88.4,
      imageUrl: 'assets/placeholder/Asset Bercak daun.png',
      gejala: 'Ditandai dengan bercak bulat berwarna cokelat kemerahan hingga cokelat tua, berbatas jelas, dan konsentris. Pada bercak yang berkembang terdapat bagian tengah berwarna putih keabu-abuan dengan kumpulan konidium jamur. Serangan berat dapat menyebabkan daun rontok.',
      penyebab: 'Disebabkan oleh jamur Cercospora coffeicola. Perkembangan penyakit dipengaruhi oleh kelembapan udara yang tinggi, terutama saat musim hujan, persemaian yang terlalu gelap, peneduh yang terlalu rimbun, serta penyinaran matahari yang terlalu kuat pada buah.',
      caraPencegahan: '• Menggunakan fungisida kimia, misalnya fungisida mancozeb seperti Dhitane dan Delsene.\n• Mengurangi kelembapan dengan mengurangi penyiraman dan menjarangkan atap penaung agar sinar matahari dapat masuk.\n• Sanitasi dengan menggunting daun yang sakit, kemudian membakarnya atau membenamkannya ke dalam tanah.',
      date: DateTime.now().subtract(const Duration(days: 15)),
    ),
    DetectionResult(
      id: 'sample_embun_jelaga',
      diseaseName: 'Embun Jelaga',
      diseaseType: 'Hama',
      confidence: 85.0,
      imageUrl: 'assets/placeholder/Asset Embun Jelaga.png',
      gejala: 'Ditandai dengan lapisan berwarna coklat hingga hitam menyerupai kotoran pada permukaan atas dan bawah daun yang dapat terkelupas apabila terkena angin. Serangan dapat menghambat fotosintesis sehingga daun menguning, layu, dan gugur.',
      penyebab: 'Perkembangan penyakit berkaitan dengan keberadaan kutu hijau (Coccus viridis), yang meningkat pada cuaca kering, terutama akhir musim kemarau. Populasi kutu hijau lebih tinggi di dataran rendah dan dapat meningkat cepat dengan bantuan semut.',
      caraPencegahan: '• Melakukan pemangkasan dan mengatur tanaman penaung agar tidak terlalu rimbun.\n• Menggunakan insektisida nabati yang paling mudah adalah dengan menggunakan air rendaman tembakau (1 kg tembakau / 2 liter air) yang diencerkan menjadi 10 kali.\n• Memanfaatkan musuh alami, seperti predator Azya luteipes dan Halmus chalybeus, parasitoid Coccophagus rusti dan Encarsia sp., serta jamur patogen Lecanicillium lecanii.',
      date: DateTime.now().subtract(const Duration(days: 20)),
    ),
    DetectionResult(
      id: 'sample_penggorok_daun',
      diseaseName: 'Penggorok Daun',
      diseaseType: 'Hama',
      confidence: 95.8,
      imageUrl: 'assets/placeholder/Asset Penggorok Daun.png',
      gejala: 'Ditandai dengan adanya alur berkelok menyerupai terowongan atau bercak pada permukaan daun. Serangan hama ini dapat mengganggu proses fotosintesis sehingga daun mengering dan akhirnya gugur.',
      penyebab: 'Disebabkan oleh larva serangga Leucoptera coffeella yang merusak jaringan daun dengan cara menggorok atau memakan bagian dalam daun. Perkembangan hama ini didukung oleh kondisi musim kemarau dan suhu yang tinggi.',
      caraPencegahan: '• Memanfaatkan musuh alami, seperti tawon parasitoid, semut, dan predator lainnya untuk menekan populasi hama.\n• Menggunakan feromon untuk mengganggu perilaku hama dan mengurangi populasinya.\n• Menggunakan insektisida neurotoksik, seperti organofosfat, karbamat, piretroid, neonicotinoid, dan diamida, dengan tetap mempertimbangkan risiko resistensi hama.',
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    DetectionResult(
      id: 'sample_hawar_daun',
      diseaseName: 'Hawar Daun',
      diseaseType: 'Jamur',
      confidence: 90.1,
      imageUrl: 'assets/placeholder/Asset Penggorok Daun-1.png',
      gejala: 'Ditandai dengan bercak cokelat kehitaman pada daun yang dapat meluas seiring perkembangan infeksi. Bercak tersebut menyebabkan jaringan daun mengalami nekrosis sehingga bagian yang terinfeksi menjadi kering.',
      penyebab: 'Disebabkan oleh jamur Phoma costaricensis. Penyakit ini berkembang pada kondisi lingkungan dengan kelembapan tinggi, suhu rendah, dan angin yang cukup kencang.',
      caraPencegahan: '• Melakukan pemangkasan dan sanitasi dengan membuang bagian tanaman yang terinfeksi untuk mengurangi sumber spora dan mencegah penyebaran penyakit.\n• Menggunakan fungisida seperti Trichoderma spp. untuk mengendalikan perkembangan patogen.',
      date: DateTime.now().subtract(const Duration(days: 25)),
    ),
    DetectionResult(
      id: 'sample_tungau_merah',
      diseaseName: 'Tungau Laba-laba Merah',
      diseaseType: 'Hama',
      confidence: 87.5,
      imageUrl: 'assets/placeholder/Asset Tungau.png',
      gejala: 'Ditandai dengan munculnya bercak-bercak kuning hingga kecokelatan pada permukaan daun akibat aktivitas pengisapan cairan sel oleh tungau. Pada serangan berat, daun tampak kusam, mengering, dan akhirnya gugur.',
      penyebab: 'Disebabkan oleh serangan hama tungau laba-laba merah dari famili Tetranychidae, seperti Oligonychus coffeae dan Tetranychus spp. Hama ini merusak daun dengan mengisap cairan sel tanaman. Perkembangannya didukung oleh kondisi cuaca kering, suhu tinggi, dan kelembapan rendah.',
      caraPencegahan: '• Menjaga kebersihan kebun dan membuang daun yang terserang.\n• Menjaga kelembapan tanaman melalui pengairan atau penyemprotan air serta memanfaatkan musuh alami, seperti Amblyseius, Phytoseiulus, dan predator lainnya.\n• Menggunakan akarisida atau insektisida sesuai tingkat serangan, seperti abamektin atau spiromesifen.',
      date: DateTime.now().subtract(const Duration(days: 30)),
    ),
    DetectionResult(
      id: 'sample_sehat',
      diseaseName: 'Daun Sehat',
      diseaseType: 'Sehat',
      confidence: 99.4,
      imageUrl: 'assets/placeholder/Asset daun sehat.png',
      gejala: 'Ditandai dengan warna hijau merata, permukaan daun halus, tepi daun utuh, serta tidak terdapat bercak, lubang, atau perubahan warna.',
      penyebab: '- (Kondisi Optimal)',
      caraPencegahan: '• Pertahankan teknik budidaya yang baik, melalui pemupukan, penyiraman, pemangkasan, dan pengelolaan naungan yang baik.\n• Menggunakan pestisida sesuai kebutuhan untuk mencegah serangan hama dan penyakit.',
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
