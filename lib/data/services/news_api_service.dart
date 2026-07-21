import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';
import '../../core/constants/api_constants.dart';

class NewsApiService {
  final http.Client _client;

  NewsApiService({http.Client? client}) : _client = client ?? http.Client();

  String get _apiKey => dotenv.env['NEWS_API_KEY'] ?? '';
  String get _baseUrl => dotenv.env['NEWS_API_BASE_URL'] ?? 'https://newsapi.org/v2';

  bool get isMockMode => _apiKey.isEmpty || _apiKey == 'isi_api_key_disini';

  Future<List<NewsArticle>> fetchTopHeadlines({
    required String category,
    required int page,
    required int pageSize,
  }) async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockHeadlines(category, page, pageSize);
    }

    // Special handling for 'all' category — fetch from all categories and interleave
    if (category == 'all') {
      return _fetchAllCategories(page: page, pageSize: pageSize);
    }

    final url = Uri.parse('$_baseUrl/top-headlines?category=$category&page=$page&pageSize=$pageSize&apiKey=$_apiKey');
    
    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'] ?? [];
        return articlesJson.map((json) => NewsArticle.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal memuat berita dari API (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  /// Fetch from all categories and interleave results
  Future<List<NewsArticle>> _fetchAllCategories({
    required int page,
    required int pageSize,
  }) async {
    final categories = ApiConstants.apiCategories;
    final articlesPerCategory = (pageSize / categories.length).ceil();
    
    try {
      final futures = categories.map((cat) => _fetchSingleCategory(cat, 1, articlesPerCategory));
      final results = await Future.wait(futures);
      
      // Interleave results from all categories
      final combined = <NewsArticle>[];
      final maxLen = results.map((r) => r.length).reduce(max);
      
      for (var i = 0; i < maxLen; i++) {
        for (final result in results) {
          if (i < result.length) {
            combined.add(result[i]);
          }
        }
      }
      
      // Paginate
      final startIndex = (page - 1) * pageSize;
      if (startIndex >= combined.length) return [];
      final endIndex = startIndex + pageSize;
      return combined.sublist(startIndex, endIndex > combined.length ? combined.length : endIndex);
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  Future<List<NewsArticle>> _fetchSingleCategory(String category, int page, int pageSize) async {
    final url = Uri.parse('$_baseUrl/top-headlines?category=$category&page=$page&pageSize=$pageSize&apiKey=$_apiKey');
    final response = await _client.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> articlesJson = data['articles'] ?? [];
      return articlesJson.map((json) => NewsArticle.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<NewsArticle>> searchNews({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    if (isMockMode) {
      await Future.delayed(const Duration(milliseconds: 800));
      return _getMockSearch(query, page, pageSize);
    }

    // Encoded query
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('$_baseUrl/everything?q=$encodedQuery&page=$page&pageSize=$pageSize&apiKey=$_apiKey');

    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'] ?? [];
        return articlesJson.map((json) => NewsArticle.fromJson(json)).toList();
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal melakukan pencarian (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  // --- DUMMY DATA ENGINE ---
  List<NewsArticle> _getMockHeadlines(String category, int page, int pageSize) {
    final List<NewsArticle> allArticles = [];
    final now = DateTime.now();

    // Handle 'all' category — combine all categories
    if (category == 'all') {
      final combined = <NewsArticle>[];
      final categories = ['sports', 'technology', 'business', 'entertainment', 'health', 'politics'];
      for (final cat in categories) {
        combined.addAll(_getMockHeadlines(cat, 1, 6));
      }
      // Shuffle interleave-like: sort by publishedAt descending
      combined.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      
      final startIndex = (page - 1) * pageSize;
      if (startIndex >= combined.length) return [];
      final endIndex = startIndex + pageSize;
      return combined.sublist(startIndex, endIndex > combined.length ? combined.length : endIndex);
    }

    if (category == 'sports') {
      allArticles.addAll([
        NewsArticle(
          title: 'Manchester United Bangkit Secara Dramatis, Kalahkan Rival Abadi di Menit Akhir',
          description: 'Setan Merah tertinggal dua gol terlebih dahulu sebelum mencetak tiga gol di babak kedua untuk mengunci kemenangan krusial.',
          sourceName: 'ESPN Sports Feed',
          author: 'Alex Ferguson Jr.',
          url: 'https://www.espn.com/soccer/',
          urlToImage: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=800',
          publishedAt: now.subtract(const Duration(hours: 1)).toIso8601String(),
          content: 'Pertandingan sengit terjadi di Old Trafford...',
        ),
        NewsArticle(
          title: 'Final NBA: Cetak 45 Poin, Mega Bintang Bawa Timnya Menuju Gelar Juara Baru',
          description: 'Performa luar biasa di kuarter keempat memastikan keunggulan mutlak dalam seri final tahun ini.',
          sourceName: 'Basketball World',
          author: 'Michael Jordan Enthusiast',
          url: 'https://www.espn.com/nba/',
          urlToImage: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800',
          publishedAt: now.subtract(const Duration(hours: 3)).toIso8601String(),
          content: 'Atmosfer arena sangat bergemuruh...',
        ),
        NewsArticle(
          title: 'Lari 100m Putra: Rekor Dunia Baru Kembali Dipecahkan di Turnamen Global',
          description: 'Pelari muda berbakat mencatatkan waktu fantastis 9.55 detik, mengalahkan rekor sebelumnya.',
          sourceName: 'Athletics Today',
          author: 'Usain Speedster',
          url: 'https://www.espn.com/olympics/',
          urlToImage: 'https://images.unsplash.com/photo-1518063319789-7217e6706b04?w=800',
          publishedAt: now.subtract(const Duration(hours: 5)).toIso8601String(),
          content: 'Sejarah baru tercipta di lintasan lari...',
        ),
        NewsArticle(
          title: 'Formula 1: Balapan Basah Monako Menghasilkan Juara Baru Secara Mengejutkan',
          description: 'Strategi ban yang berani di tengah hujan badai membawa pembalap rookie menaiki podium tertinggi.',
          sourceName: 'F1 News',
          author: 'Lewis Speed',
          url: 'https://www.espn.com/f1/',
          urlToImage: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800',
          publishedAt: now.subtract(const Duration(hours: 8)).toIso8601String(),
          content: 'Monako selalu menghadirkan drama tak terduga...',
        ),
        NewsArticle(
          title: 'Indonesia Juara Umum Kejuaraan Bulu Tangkis Beregu Asia 2026',
          description: 'Kemenangan bersih di sektor tunggal putra dan ganda campuran memastikan trofi pulang ke tanah air.',
          sourceName: 'Badminton Indo',
          author: 'Gideon Smash',
          url: 'https://www.badmintonindonesia.org',
          urlToImage: 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800',
          publishedAt: now.subtract(const Duration(days: 1)).toIso8601String(),
          content: 'Laga final berjalan dengan ketegangan tinggi...',
        ),
        NewsArticle(
          title: 'Pecahkan Rekor, Transfer Pemain Termahal Musim Dingin Resmi Disepakati',
          description: 'Klub raksasa Eropa merogoh kocek hingga 150 juta Euro untuk mengontrak penyerang muda berbakat.',
          sourceName: 'Soccer News',
          author: 'Fabrizio Romano Tribute',
          url: 'https://www.espn.com/soccer/',
          urlToImage: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=800',
          publishedAt: now.subtract(const Duration(days: 1, hours: 4)).toIso8601String(),
          content: 'Here we go! Negosiasi akhirnya selesai malam ini...',
        )
      ]);
    } else if (category == 'technology') {
      allArticles.addAll([
        NewsArticle(
          title: 'Generasi Baru Asisten AI Diperkenalkan: Lebih Pintar, Lebih Cepat, dan Multimodal',
          description: 'Model AI terbaru ini mampu berinteraksi secara real-time dengan video, suara, dan kode secara bersamaan.',
          sourceName: 'TechCrunch Daily',
          author: 'Sam Altman Fan',
          url: 'https://techcrunch.com',
          urlToImage: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800',
          publishedAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
          content: 'Era komputasi kognitif baru saja dimulai...',
        ),
        NewsArticle(
          title: 'Apple Merilis Laptop Super Tipis Baru dengan Chipset Fabrikasi 2nm',
          description: 'Masa pakai baterai diklaim mencapai 30 jam dengan performa pemrosesan grafis dua kali lipat lebih cepat.',
          sourceName: 'MacRumors',
          author: 'Tim Cook Companion',
          url: 'https://www.macrumors.com',
          urlToImage: 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=800',
          publishedAt: now.subtract(const Duration(hours: 4)).toIso8601String(),
          content: 'Apple kembali menggebrak pasar laptop tipis...',
        ),
        NewsArticle(
          title: 'Misi Artemis Sukses: Kapsul Ruang Angkasa Kembali ke Bumi Setelah Orbit Bulan',
          description: 'Pendaratan mulus di Samudra Pasifik menandai langkah besar manusia untuk kembali mendarat di Bulan.',
          sourceName: 'Space Exploration',
          author: 'Elon Rocket',
          url: 'https://www.nasa.gov',
          urlToImage: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800',
          publishedAt: now.subtract(const Duration(hours: 6)).toIso8601String(),
          content: 'NASA merayakan kesuksesan misi Artemis kali ini...',
        ),
        NewsArticle(
          title: 'Cybersecurity Alert: Celah Keamanan Zero-Day Ditemukan pada Browser Populer',
          description: 'Pengguna diimbau segera memperbarui aplikasi browser mereka untuk menghindari pencurian data kredensial.',
          sourceName: 'Wired Security',
          author: 'Kevin Mitnick Jr.',
          url: 'https://www.wired.com',
          urlToImage: 'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=800',
          publishedAt: now.subtract(const Duration(hours: 12)).toIso8601String(),
          content: 'Peneliti keamanan siber menemukan eksploitasi aktif...',
        ),
        NewsArticle(
          title: 'Konsol Game Portabel Generasi Terbaru Janjikan Visual Kualitas Konsol Rumahan',
          description: 'Dilengkapi dengan layar OLED 120Hz dan dukungan ray tracing portabel secara real-time.',
          sourceName: 'IGN Tech',
          author: 'Gamer Master',
          url: 'https://www.ign.com',
          urlToImage: 'https://images.unsplash.com/photo-1605901309584-818e25960a8f?w=800',
          publishedAt: now.subtract(const Duration(days: 1)).toIso8601String(),
          content: 'Pasar konsol genggam semakin memanas dengan kedatangan...',
        )
      ]);
    } else    if (category == 'business') {
      allArticles.addAll([
        NewsArticle(
          title: 'Pasar Saham Global Melonjak Setelah Pengumuman Penurunan Suku Bunga Federal Reserve',
          description: 'Indeks utama mencatatkan rekor tertinggi baru seiring meningkatnya optimisme investor terhadap ekonomi global.',
          sourceName: 'Bloomberg News',
          author: 'Warren Buffet Student',
          url: 'https://www.bloomberg.com',
          urlToImage: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=800',
          publishedAt: now.subtract(const Duration(hours: 1)).toIso8601String(),
          content: 'Kebijakan moneter baru memberikan sentimen positif...',
        ),
        NewsArticle(
          title: 'Raksasa Otomotif Investasikan 10 Miliar Dollar untuk Pabrik Baterai EV Raksasa',
          description: 'Langkah strategis ini diambil guna memenuhi target elektrifikasi armada kendaraan secara penuh pada tahun 2030.',
          sourceName: 'Wall Street Journal',
          author: 'Henry Ford III',
          url: 'https://www.wsj.com',
          urlToImage: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800',
          publishedAt: now.subtract(const Duration(hours: 4)).toIso8601String(),
          content: 'Pembangunan pabrik baterai listrik berskala besar ini...',
        ),
        NewsArticle(
          title: 'Startup FinTech Lokal Raih Pendanaan Seri B Sebesar 50 Juta Dollar',
          description: 'Dana segar akan digunakan untuk ekspansi pasar ke Asia Tenggara dan pengembangan produk AI keuangan.',
          sourceName: 'TechInAsia',
          author: 'Unicorn Seeker',
          url: 'https://www.techinasia.com',
          urlToImage: 'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?w=800',
          publishedAt: now.subtract(const Duration(hours: 7)).toIso8601String(),
          content: 'Sektor FinTech terus menunjukkan ketahanan luar biasa...',
        ),
        NewsArticle(
          title: 'Inflasi Nasional Turun ke Level Terendah dalam Dua Tahun Terakhir',
          description: 'Harga kebutuhan pokok mulai stabil berkat rantai pasokan domestik yang kembali pulih sepenuhnya.',
          sourceName: 'Investor Daily',
          author: 'Keynesian Advocate',
          url: 'https://www.investor.id',
          urlToImage: 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=800',
          publishedAt: now.subtract(const Duration(hours: 20)).toIso8601String(),
          content: 'Laporan Badan Pusat Statistik menunjukkan penurunan inflasi...',
        ),
        NewsArticle(
          title: 'Industri Kopi Lokal Tembus Pasar Ekspor Eropa dengan Nilai Kontrak Fantastis',
          description: 'Koperasi petani kopi berhasil mengamankan ekspor berkelanjutan berkat standar kualitas organik bersertifikat.',
          sourceName: 'Business Insider',
          author: 'Barista Business',
          url: 'https://www.businessinsider.com',
          urlToImage: 'https://images.unsplash.com/photo-1447933601403-0c6688de566e?w=800',
          publishedAt: now.subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
          content: 'Ekspor kopi arabika Indonesia mengalami kenaikan tajam...',
        )
      ]);
    } else if (category == 'entertainment') {
      allArticles.addAll([
        NewsArticle(
          title: 'Film Animasi Indonesia Tembus Box Office Global dengan Cerita Budaya Nusantara',
          description: 'Animasi garapan studio lokal sukses meraup lebih dari 500 miliar rupiah di bioskop seluruh dunia.',
          sourceName: 'Cultur3 Mag',
          author: 'Anime Lover',
          url: 'https://www.hollywoodreporter.com',
          urlToImage: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800',
          publishedAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
          content: 'Dunia perfilman Tanah Air patut berbangga...',
        ),
        NewsArticle(
          title: 'Konser Virtual Artis K-Pop Global Catat 10 Juta Penonton Serentak',
          description: 'Teknologi extended reality (XR) menghadirkan pengalaman konser hiper-realistis untuk penggemar di 150 negara.',
          sourceName: 'Kpop Wave',
          author: 'Hallyu Fan',
          url: 'https://www.billboard.com',
          urlToImage: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800',
          publishedAt: now.subtract(const Duration(hours: 5)).toIso8601String(),
          content: 'Gelombang Hallyu kembali mencetak sejarah...',
        ),
        NewsArticle(
          title: 'Serial Dokumenter Netflix tentang Sejarah Musik Dangdut Raup Pujian Kritikus',
          description: 'Serial 6 episode ini berhasil memperkenalkan kekayaan musik tradisional Indonesia ke panggung internasional.',
          sourceName: 'Screen Daily',
          author: 'Film Critic',
          url: 'https://www.netflix.com',
          urlToImage: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800',
          publishedAt: now.subtract(const Duration(hours: 10)).toIso8601String(),
          content: 'Netflix kembali menunjukkan komitmennya...',
        ),
        NewsArticle(
          title: 'Game Lokal Bertema Mitologi Indonesia Masuk Nominasi Game Awards 2026',
          description: 'Game action-adventure dengan latar kerajaan Majapahit bersaing di kategori Best Indie Game tahun ini.',
          sourceName: 'IGN Indonesia',
          author: 'Gamer Geek',
          url: 'https://www.ign.com',
          urlToImage: 'https://images.unsplash.com/photo-1552820728-8b83bb6b10f7?w=800',
          publishedAt: now.subtract(const Duration(hours: 14)).toIso8601String(),
          content: 'Industri game Indonesia semakin diperhitungkan...',
        ),
      ]);
    } else if (category == 'health') {
      allArticles.addAll([
        NewsArticle(
          title: 'Vaksin Kanker Terobosan Baru Mulai Uji Klinis Fase 3 di Asia Tenggara',
          description: 'Vaksin berbasis mRNA yang dikembangkan ilmuwan lokal menunjukkan tingkat keberhasilan 85% pada uji awal.',
          sourceName: 'Health Today',
          author: 'Dr. Medica',
          url: 'https://www.who.int',
          urlToImage: 'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=800',
          publishedAt: now.subtract(const Duration(hours: 3)).toIso8601String(),
          content: 'Kabar baik datang dari dunia kedokteran Indonesia...',
        ),
        NewsArticle(
          title: 'Studi Terbaru: Olahraga 10 Menit Sehari Bisa Kurangi Risiko Penyakit Jantung Hingga 30%',
          description: 'Penelitian kolaborasi 5 universitas menunjukkan durasi olahraga pendek namun konsisten sangat efektif.',
          sourceName: 'Medical Journal',
          author: 'Fit Researcher',
          url: 'https://www.healthline.com',
          urlToImage: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
          publishedAt: now.subtract(const Duration(hours: 6)).toIso8601String(),
          content: 'Tidak perlu olahraga berat setiap hari...',
        ),
        NewsArticle(
          title: 'Kemenkes Luncurkan Program Deteksi Dini Kesehatan Mental Pelajar Nasional',
          description: 'Program berbasis sekolah ini menargetkan screening kesehatan mental untuk 10 juta pelajar di seluruh Indonesia.',
          sourceName: 'Kemenkes RI',
          author: 'Biro Komunikasi',
          url: 'https://www.kemkes.go.id',
          urlToImage: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800',
          publishedAt: now.subtract(const Duration(hours: 12)).toIso8601String(),
          content: 'Kesadaran akan kesehatan mental semakin meningkat...',
        ),
        NewsArticle(
          title: 'Superfood Lokal Indonesia: Tempe Dinobatkan Sebagai Makanan Tersehat Versi Global Nutrition Index',
          description: 'Kandungan protein, vitamin B12, dan probiotik alami tempe mengalahkan quinoa dan kale dalam indeks nutrisi.',
          sourceName: 'Nutrition Daily',
          author: 'Vegan Power',
          url: 'https://www.nutrition.org',
          urlToImage: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
          publishedAt: now.subtract(const Duration(hours: 18)).toIso8601String(),
          content: 'Tempe kembali mencuri perhatian dunia...',
        ),
      ]);
    } else if (category == 'politics') {
      allArticles.addAll([
        NewsArticle(
          title: 'DPR Sahkan RUU Omnibus Law Versi Revisi: Dampak Besar bagi Dunia Usaha',
          description: 'Setelah melalui pembahasan alot selama 8 bulan, DPR akhirnya mengesahkan RUU kontroversial ini dengan 287 suara setuju.',
          sourceName: 'Kompas Politik',
          author: 'Parlementaria',
          url: 'https://www.kompas.com',
          urlToImage: 'https://images.unsplash.com/photo-1529543544282-ea114074bc5e?w=800',
          publishedAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
          content: 'Sidang paripurna DRI berlangsung alot hingga larut malam...',
        ),
        NewsArticle(
          title: 'Pemilihan Kepala Daerah Serentak: 37 Provinsi Siap Gelar Pemilihan November Mendatang',
          description: 'KPU menyatakan kesiapan penuh dengan daftar pemilih tetap mencapai 180 juta jiwa dan 1.200 pasangan calon terdaftar.',
          sourceName: 'Detik News',
          author: 'Pemilu Watch',
          url: 'https://www.detik.com',
          urlToImage: 'https://images.unsplash.com/photo-1540910419892-4a36d2c3266c?w=800',
          publishedAt: now.subtract(const Duration(hours: 5)).toIso8601String(),
          content: 'Tahapan Pilkada Serentak 2026 memasuki babak krusial...',
        ),
        NewsArticle(
          title: 'Presiden dan Oposisi Sepakat Bentuk Tim Reformasi Birokrasi untuk Pemberantasan Korupsi',
          description: 'Kesepakatan bersejarah ini disambut positif oleh publik dan menandai babak baru kerja sama partai politik di Indonesia.',
          sourceName: 'TempoNews',
          author: 'Reformis Muda',
          url: 'https://www.tempo.com',
          urlToImage: 'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800',
          publishedAt: now.subtract(const Duration(hours: 8)).toIso8601String(),
          content: 'Isu pemberantasan korupsi kembali menghangat di panggung politik...',
        ),
        NewsArticle(
          title: 'Menteri Luar Negeri Dorong Kerja Sama ASEAN Hadapi Krisis Regional Myamar',
          description: 'Indonesia kembali mengambil peran sebagai mediator dalam konflik yang telah berlangsung lebih dari 5 tahun di kawasan.',
          sourceName: 'Antara News',
          author: 'Diplomat Watch',
          url: 'https://www.antaranews.com',
          urlToImage: 'https://images.unsplash.com/photo-1559827291-baf8f0f60cef?w=800',
          publishedAt: now.subtract(const Duration(hours: 12)).toIso8601String(),
          content: 'Politik luar negeri Indonesia kembali diuji...',
        ),
        NewsArticle(
          title: 'APBN 2026 Disepakati: Alokasi Pendidikan dan Kesehatan di Atas 20% Total Anggaran',
          description: 'Kesepakatan antara DPR dan pemerintah menempatkan pendidikan dan kesehatan sebagai prioritas utama pembangunan nasional 2026.',
          sourceName: 'CNBC Indonesia',
          author: 'Anggaran Ahli',
          url: 'https://www.cnbcindonesia.com',
          urlToImage: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800',
          publishedAt: now.subtract(const Duration(hours: 18)).toIso8601String(),
          content: 'Postur APBN tahun ini dinilai lebih berpihak pada rakyat...',
        ),
        NewsArticle(
          title: 'Partai Politik Baru Resmi Terdaftar di KPU, Targetkan Kursi DPR pada Pemilu 2029',
          description: 'Partai dengan basis pemilih milenial ini mengusung platform transparansi digital dan anti-korupsi sebagai isu utama.',
          sourceName: 'Kumparan News',
          author: 'Politisi Millennial',
          url: 'https://www.kumparan.com',
          urlToImage: 'https://images.unsplash.com/photo-1532629345422-7515f3d16bb6?w=800',
          publishedAt: now.subtract(const Duration(days: 1)).toIso8601String(),
          content: 'Kancah politik Indonesia kedatangan pemain baru...',
        ),
      ]);
    }

    // Handle dummy pagination
    final startIndex = (page - 1) * pageSize;
    if (startIndex >= allArticles.length) {
      return [];
    }
    
    final endIndex = startIndex + pageSize;
    final limitedArticles = allArticles.sublist(
      startIndex,
      endIndex > allArticles.length ? allArticles.length : endIndex,
    );

    return limitedArticles;
  }

  List<NewsArticle> _getMockSearch(String query, int page, int pageSize) {
    // Generate all headlines to search from
    final List<NewsArticle> allArticles = [];
    allArticles.addAll(_getMockHeadlines('sports', 1, 50));
    allArticles.addAll(_getMockHeadlines('technology', 1, 50));
    allArticles.addAll(_getMockHeadlines('business', 1, 50));
    allArticles.addAll(_getMockHeadlines('entertainment', 1, 50));
    allArticles.addAll(_getMockHeadlines('health', 1, 50));

    // Filter by query
    final lowerQuery = query.toLowerCase();
    final filteredArticles = allArticles.where((article) {
      return article.title.toLowerCase().contains(lowerQuery) ||
             (article.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();

    // Paginate
    final startIndex = (page - 1) * pageSize;
    if (startIndex >= filteredArticles.length) {
      return [];
    }

    final endIndex = startIndex + pageSize;
    return filteredArticles.sublist(
      startIndex,
      endIndex > filteredArticles.length ? filteredArticles.length : endIndex,
    );
  }
}
