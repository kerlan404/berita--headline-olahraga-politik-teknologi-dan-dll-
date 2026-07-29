import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';
import '../../core/constants/api_constants.dart';

class NewsApiService {
  final http.Client _client;

  NewsApiService({http.Client? client}) : _client = client ?? http.Client();

  String get _apiKey => dotenv.env['NEWS_API_KEY'] ?? '';
  String? get _corsProxyUrl => dotenv.env['CORS_PROXY_URL'];

  /// On web with CORS proxy: use proxy URL as base
  /// On native or web without proxy: use direct NewsAPI URL
  String get _baseUrl {
    if (kIsWeb) {
      final proxy = _corsProxyUrl;
      if (proxy != null && proxy.isNotEmpty) {
        return proxy;
      }
    }
    return dotenv.env['NEWS_API_BASE_URL'] ?? 'https://newsapi.org/v2';
  }

  // Web without CORS proxy → use mock data (NewsAPI blocks CORS)
  // Native (Android/iOS/Desktop) → real API when key is available
  bool get isMockMode {
    if (kIsWeb) {
      final proxy = _corsProxyUrl;
      // If proxy is configured, use real API via proxy
      if (proxy != null && proxy.isNotEmpty) return false;
      // No proxy on web → must use mock
      return true;
    }
    return _apiKey.isEmpty || _apiKey == 'isi_api_key_disini';
  }

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

    // NewsAPI doesn't support 'politics' category — map to 'general'
    final apiCategory = (category == 'politics') ? 'general' : category;

    final url = Uri.parse('$_baseUrl/top-headlines?category=$apiCategory&page=$page&pageSize=$pageSize&apiKey=$_apiKey');
    
    try {
      final response = await _client.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'] ?? [];
        if (articlesJson.isNotEmpty) {
          return articlesJson.map((json) => NewsArticle.fromJson(json)).toList();
        }
      }
      // API gagal atau tidak ada artikel → fallback ke mock data
      debugPrint('NewsApiService: API returned no data, using mock fallback');
      return _getMockHeadlines(category, page, pageSize);
    } catch (e) {
      debugPrint('NewsApiService: API error, using mock fallback — $e');
      return _getMockHeadlines(category, page, pageSize);
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
      
      // Jika semua kategori gagal (API key invalid / network error)
      final allEmpty = results.every((r) => r.isEmpty);
      if (allEmpty) {
        return _getMockHeadlines('all', page, pageSize);
      }

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
      // Fallback ke mock data
      return _getMockHeadlines('all', page, pageSize);
    }
  }

  Future<List<NewsArticle>> _fetchSingleCategory(String category, int page, int pageSize) async {
    // NewsAPI doesn't support 'politics' category — map to 'general'
    final apiCategory = (category == 'politics') ? 'general' : category;
    final url = Uri.parse('$_baseUrl/top-headlines?category=$apiCategory&page=$page&pageSize=$pageSize&apiKey=$_apiKey');
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
        if (articlesJson.isNotEmpty) {
          return articlesJson.map((json) => NewsArticle.fromJson(json)).toList();
        }
      }
      // API gagal → fallback ke mock search
      return _getMockSearch(query, page, pageSize);
    } catch (e) {
      // Fallback ke mock search
      return _getMockSearch(query, page, pageSize);
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
        combined.addAll(_getMockHeadlines(cat, 1, 50));
      }
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
        ),
        NewsArticle(
          title: 'Timnas Indonesia U-23 Lolos ke Semifinal Piala Asia dengan Kemenangan Telak 4-0',
          description: 'Empat gol tanpa balas di babak perempat final memastikan langkah Garuda Muda ke empat besar.',
          sourceName: 'Bola.com',
          author: 'Rizal Permadi',
          url: 'https://www.bola.com',
          urlToImage: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800',
          publishedAt: now.subtract(const Duration(hours: 6)).toIso8601String(),
          content: 'Timnas Indonesia U-23 bermain gemilang di babak perempat final...',
        ),
        NewsArticle(
          title: 'Persija Jakarta Resmi Gaet Striker Bintang Brasil untuk Musim Kompetisi 2026',
          description: 'Pemain berusia 27 tahun ini didatangkan dari klub Serie A Italia dengan kontrak 3 musim penuh.',
          sourceName: 'Transfermarkt Indo',
          author: 'Bursa Transfer',
          url: 'https://www.transfermarkt.com',
          urlToImage: 'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800',
          publishedAt: now.subtract(const Duration(hours: 10)).toIso8601String(),
          content: 'Macan Kemayoran kembali mempersenjatai skuad...',
        ),
        NewsArticle(
          title: 'Marathon Tokyo 2026: Pelari Kenya Pecahkan Rekor Dunia Baru dengan Waktu 1:59:40',
          description: 'Untuk pertama kalinya dalam sejarah, pelari marathon berhasil menembus batas waktu 2 jam di kondisi balapan resmi.',
          sourceName: 'World Athletics',
          author: 'Run Planet',
          url: 'https://worldathletics.org',
          urlToImage: 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800',
          publishedAt: now.subtract(const Duration(hours: 14)).toIso8601String(),
          content: 'Sejarah tercipta di jalanan Tokyo pagi ini...',
        ),
        NewsArticle(
          title: 'Asian Games 2026: Indonesia Raih 15 Emas dan Pecahkan Target Awal',
          description: 'Kontingen Merah Putih sukses melampaui target 12 emas yang ditetapkan KONI Pusat.',
          sourceName: 'Olympic Channel',
          author: 'Giri Satria',
          url: 'https://olympics.com',
          urlToImage: 'https://images.unsplash.com/photo-1569517282132-25d22f4573e6?w=800',
          publishedAt: now.subtract(const Duration(days: 1, hours: 2)).toIso8601String(),
          content: 'Indonesia menunjukkan dominasi di beberapa cabang olahraga...',
        ),
        NewsArticle(
          title: 'Liga Champions: Real Madrid Comeback Epik dari Ketinggalan 0-3 untuk Lolos ke Final',
          description: 'Tiga gol di babak kedua termasuk gol penyeimbang di injury time menghidupkan mimpi Los Blancos.',
          sourceName: 'UEFA.com',
          author: 'Champions League Reporter',
          url: 'https://www.uefa.com',
          urlToImage: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=800',
          publishedAt: now.subtract(const Duration(days: 2)).toIso8601String(),
          content: 'Santiago Bernabeu menyaksikan malam ajaib...',
        ),
        // Extra sports articles for pagination
        NewsArticle(
          title: 'UEFA Euro 2028 Ditunjuk: Inggris, Irlandia, Skotlandia, Wales Sukses Jadi Tuan Rumah Bersama',
          description: 'Empat negara Britania Raya resmi ditunjuk UEFA menjadi tuan rumah bersama Euro 2028 setelah proses bidding yang ketat.',
          sourceName: 'BBC Sports',
          author: 'Sports Reporter',
          url: 'https://www.bbc.com/sport',
          urlToImage: 'https://images.unsplash.com/photo-1459865264687-595d652de67e?w=800',
          publishedAt: now.subtract(const Duration(hours: 7)).toIso8601String(),
          content: 'Keputusan UEFA ini diumumkan di markas mereka di Nyon...',
        ),
        NewsArticle(
          title: 'Jonatan Christie Juara Indonesia Masters 2026 Usai Kalahkan Wakil Denmark',
          description: 'Pebulutangkis tunggal putra andalan Indonesia berhasil menundukkan lawan beratnya di partai final yang berlangsung sengit.',
          sourceName: 'Olahraga TV',
          author: 'Badminton Fan',
          url: 'https://www.olahragatv.com',
          urlToImage: 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800',
          publishedAt: now.subtract(const Duration(hours: 9)).toIso8601String(),
          content: 'Pertandingan final berlangsung selama tiga game...',
        ),
        NewsArticle(
          title: 'MotoGP Mandalika 2026: Pembalap Indonesia Raih Podium Kedua Setelah Perlombaan Dramatis',
          description: 'Hujan deras yang turun 5 lap menjelang finis mengacaukan strategi banyak pembalap top dunia.',
          sourceName: 'MotoGP News',
          author: 'Racing Insider',
          url: 'https://www.motogp.com',
          urlToImage: 'https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?w=800',
          publishedAt: now.subtract(const Duration(hours: 4)).toIso8601String(),
          content: 'Sirkuit Mandalaya kembali menyajikan pertunjukan yang menakjubkan...',
        ),
        NewsArticle(
          title: 'Tim Basket Putri Indonesia Lolos Olimpiade 2028 untuk Pertama Kalinya',
          description: 'Kemenangan atas tuan rumah di final kualifikasi zona Asia memastikan tiket bersejarah ke panggung olahraga tertinggi.',
          sourceName: 'FIBA Asia',
          author: 'Basketball Insider',
          url: 'https://www.fiba.basketball',
          urlToImage: 'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800',
          publishedAt: now.subtract(const Duration(days: 1, hours: 6)).toIso8601String(),
          content: 'Sejarah baru terukir untuk basket putri Indonesia...',
        ),
        NewsArticle(
          title: 'Anthony Ginting Umumkan Pensiun dari Bulu Tangkis Profesional Usai 15 Tahun Berkarier',
          description: 'Pebulutangkis legendaris Indonesia ini memutuskan gantung raket setelah mempersembahkan puluhan gelar internasional.',
          sourceName: 'BWF News',
          author: 'Badminton Legend',
          url: 'https://bwfbadminton.com',
          urlToImage: 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800',
          publishedAt: now.subtract(const Duration(days: 2, hours: 4)).toIso8601String(),
          content: 'Dunia bulu tangkis Indonesia kehilangan salah satu putra terbaiknya...',
        ),
        NewsArticle(
          title: 'Piala Dunia 2030: Indonesia Resmi Jadi Salah Satu Tuan Rumah Bersama',
          description: 'FIFA mengumumkan Indonesia sebagai salah satu tuan rumah Piala Dunia 2030 bersama dengan Australia dan Selandia Baru.',
          sourceName: 'FIFA.com',
          author: 'World Soccer',
          url: 'https://www.fifa.com',
          urlToImage: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=800',
          publishedAt: now.subtract(const Duration(days: 3)).toIso8601String(),
          content: 'Kabar gembira bagi pecinta sepak bola Indonesia...',
        ),
        NewsArticle(
          title: 'Kevin Sanjaya dan Marcus Gideon Resmi Pensiun, Akhiri Era Keemasan Ganda Putra Indonesia',
          description: 'Pasangan ganda putra legendaris Indonesia memutuskan pensiun bersama di usia 32 tahun.',
          sourceName: 'Bola Sport',
          author: 'Badminton Analyst',
          url: 'https://www.bolasport.com',
          urlToImage: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800',
          publishedAt: now.subtract(const Duration(days: 3, hours: 8)).toIso8601String(),
          content: 'Era Minions di dunia bulu tangkis resmi berakhir...',
        ),
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
        ),
        NewsArticle(
          title: 'Samsung Galaxy S26 Ultra Resmi Diluncurkan dengan Kamera 200MP dan AI Fotografi Generatif',
          description: 'Ponsel flagship terbaru Samsung menghadirkan kemampuan editing foto berbasis AI yang bisa mengubah komposisi gambar secara instan.',
          sourceName: 'GSMArena',
          author: 'Gadget Insider',
          url: 'https://www.gsmarena.com',
          urlToImage: 'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=800',
          publishedAt: now.subtract(const Duration(hours: 3)).toIso8601String(),
          content: 'Samsung kembali mendefinisikan ulang fotografi mobile...',
        ),
        NewsArticle(
          title: 'Startup Unicorn Indonesia Luncurkan Platform Cloud Computing Berbasis AI untuk UMKM',
          description: 'Platform lokal ini menawarkan solusi otomatisasi bisnis dengan harga terjangkau untuk pelaku UMKM di seluruh Indonesia.',
          sourceName: 'TechInAsia',
          author: 'Startup Watch',
          url: 'https://www.techinasia.com',
          urlToImage: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800',
          publishedAt: now.subtract(const Duration(hours: 8)).toIso8601String(),
          content: 'Digitalisasi UMKM Indonesia mendapat dorongan besar...',
        ),
        NewsArticle(
          title: 'Blockchain dan Web3: Indonesia Jadi Negara dengan Pertumbuhan Adopsi Crypto Tercepat di Asia',
          description: 'Jumlah pengguna cryptocurrency di Indonesia melonjak 45% dalam setahun terakhir berkat edukasi regulasi yang baik.',
          sourceName: 'CoinDesk',
          author: 'Crypto Reporter',
          url: 'https://www.coindesk.com',
          urlToImage: 'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=800',
          publishedAt: now.subtract(const Duration(hours: 15)).toIso8601String(),
          content: 'Adopsi aset digital di Indonesia terus menunjukkan tren positif...',
        ),
        NewsArticle(
          title: 'Elon Musk Umumkan Starlink Gen-3: Kecepatan Internet Satelit Capai 1 Gbps di Mana Saja',
          description: 'Generasi ketiga Starlink menjanjikan покрытие 99% permukaan bumi dengan latensi super rendah.',
          sourceName: 'Space.com',
          author: 'Tech Frontier',
          url: 'https://www.space.com',
          urlToImage: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=800',
          publishedAt: now.subtract(const Duration(days: 1)).toIso8601String(),
          content: 'Internet satelit memasuki era baru dengan Starlink Gen-3...',
        ),
        NewsArticle(
          title: 'Google DeepMind Temukan Algoritma Baru yang Bisa Prediksi Gempa Bumi 72 Jam Sebelum Terjadi',
          description: 'Model machine learning ini menunjukkan akurasi 87% dalam uji coba di zona subduksi Cincin Api Pasifik.',
          sourceName: 'Nature Journal',
          author: 'AI Researcher',
          url: 'https://www.nature.com',
          urlToImage: 'https://images.unsplash.com/photo-1504868584819-f8e8b4b6d7e3?w=800',
          publishedAt: now.subtract(const Duration(days: 1, hours: 6)).toIso8601String(),
          content: 'Terobosan besar dalam prediksi bencana alam...',
        ),
        NewsArticle(
          title: 'Meta Quest 4 Resmi Rilis: Realitas Virtual dengan Resolusi 8K per Mata dan Haptic Suit',
          description: 'Headset VR terbaru Meta menawarkan pengalaman immersion yang belum pernah ada sebelumnya.',
          sourceName: 'The Verge',
          author: 'VR Enthusiast',
          url: 'https://www.theverge.com',
          urlToImage: 'https://images.unsplash.com/photo-1622979135225-d2ba269cf1ac?w=800',
          publishedAt: now.subtract(const Duration(days: 2)).toIso8601String(),
          content: 'Realitas virtual semakin mendekati fiksi ilmiah...',
        ),
        // Extra tech articles for pagination
        NewsArticle(
          title: 'Teknologi 6G Mulai Diujicobakan di Indonesia, Kecepatan 100 Kali Lipat dari 5G',
          description: 'Kemenkominfo bersama operator seluler mulai menggelar uji coba teknologi 6G di beberapa kota besar.',
          sourceName: 'Kominfo News',
          author: 'Tech Analyst',
          url: 'https://www.kominfo.go.id',
          urlToImage: 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?w=800',
          publishedAt: now.subtract(const Duration(hours: 5)).toIso8601String(),
          content: 'Indonesia tidak ingin tertinggal dalam pengembangan teknologi jaringan generasi keenam...',
        ),
        NewsArticle(
          title: 'OpenAI Rilis GPT-6 dengan Kemampuan Penalaran Setara Manusia Ahli',
          description: 'Model bahasa terbaru ini mampu menyelesaikan persamaan matematika kompleks dan menulis kode aplikasi lengkap.',
          sourceName: 'OpenAI Blog',
          author: 'AI Watcher',
          url: 'https://openai.com',
          urlToImage: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800',
          publishedAt: now.subtract(const Duration(hours: 10)).toIso8601String(),
          content: 'Terobosan terbaru di dunia kecerdasan buatan...',
        ),
        NewsArticle(
          title: 'Robot Humanoid Pertama Buatan Indonesia Mulai Diproduksi Massal',
          description: 'Startup robotika asal Bandung berhasil memproduksi robot humanoid dengan harga 10 kali lebih murah dari impor.',
          sourceName: 'Teknologi Indonesia',
          author: 'Robotic Engineer',
          url: 'https://www.technologyindonesia.com',
          urlToImage: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800',
          publishedAt: now.subtract(const Duration(hours: 14)).toIso8601String(),
          content: 'Industri robotika Indonesia mencatat sejarah baru...',
        ),
        NewsArticle(
          title: 'WhatsApp Luncurkan Fitur AI Translator Real-Time untuk Chat Antar Bahasa',
          description: 'Fitur baru ini memungkinkan pengguna berkomunikasi lintas bahasa secara instan tanpa aplikasi pihak ketiga.',
          sourceName: 'WhatsApp Blog',
          author: 'Messaging Insider',
          url: 'https://blog.whatsapp.com',
          urlToImage: 'https://images.unsplash.com/photo-1611605698335-8b1569810432?w=800',
          publishedAt: now.subtract(const Duration(days: 1)).toIso8601String(),
          content: 'Meta kembali menghadirkan inovasi pada platform messaging terbesarnya...',
        ),
        NewsArticle(
          title: 'Gojek dan Grab Uji Coba Layanan Taksi Terbang Listrik di Langit Jakarta',
          description: 'Layanan taksi terbang dengan teknologi eVTOL ini dijadwalkan beroperasi komersial tahun depan.',
          sourceName: 'Urban Mobility',
          author: 'Transport Tech',
          url: 'https://www.urbanmobility.com',
          urlToImage: 'https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=800',
          publishedAt: now.subtract(const Duration(days: 1, hours: 12)).toIso8601String(),
          content: 'Masa depan transportasi perkotaan semakin dekat...',
        ),
        NewsArticle(
          title: 'NVIDIA Umumkan Chip AI Terbaru dengan 10 Triliun Transistor untuk Pusat Data',
          description: 'Chip Blackwell Ultra ini diklaim mampu melatih model AI 30 kali lebih cepat dari generasi sebelumnya.',
          sourceName: 'NVIDIA News',
          author: 'GPU Enthusiast',
          url: 'https://www.nvidia.com',
          urlToImage: 'https://images.unsplash.com/photo-1555617778-6e859c0603e0?w=800',
          publishedAt: now.subtract(const Duration(days: 2, hours: 6)).toIso8601String(),
          content: 'Persaingan industri chip AI semakin memanas...',
        ),
        NewsArticle(
          title: 'Indonesia Luncurkan Satelit Internet Nusantara-1 untuk Daerah 3T',
          description: 'Satelit dengan kapasitas 500 Gbps ini akan menyediakan akses internet gratis untuk 10.000 desa tertinggal.',
          sourceName: 'BRIN',
          author: 'Space Tech',
          url: 'https://www.brin.go.id',
          urlToImage: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800',
          publishedAt: now.subtract(const Duration(days: 3)).toIso8601String(),
          content: 'Indonesia memasuki babak baru konektivitas nasional...',
        ),
      ]);
    } else if (category == 'business') {
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
        ),
        NewsArticle(
          title: 'GoTo dan Bukalapak Umumkan Merger Bersejarah, Menciptakan Raksasa E-Commerce Terbesar di Asia Tenggara',
          description: 'Dua platform e-commerce terbesar Indonesia bergabung untuk bersaing dengan Shark dan TikTok Shop di pasar regional.',
          sourceName: 'KrASIA',
          author: 'Deal Reporter',
          url: 'https://www.krasia.com',
          urlToImage: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800',
          publishedAt: now.subtract(const Duration(hours: 5)).toIso8601String(),
          content: 'Merger ini mengubah lanskap e-commerce Asia Tenggara...',
        ),
        NewsArticle(
          title: 'Harga Emas Antam Tembus Rp 1,2 Juta per Gram, Analis: Masih Ada Potensi Naik',
          description: 'Ketidakpastian geopolitik global dan pelemahan dolar mendorong permintaan terhadap aset safe haven.',
          sourceName: 'CNBC Indonesia',
          author: 'Market Analyst',
          url: 'https://www.cnbcindonesia.com',
          urlToImage: 'https://images.unsplash.com/photo-1610375461246-83df859d849d?w=800',
          publishedAt: now.subtract(const Duration(hours: 9)).toIso8601String(),
          content: 'Pasar komoditas emas terus menunjukkan tren naik...',
        ),
        NewsArticle(
          title: 'Bank Indonesia Uji Coba CBDC Digital Rupiah pada 10 Bank Konvensional',
          description: 'Pilot project mata uang digital bank sentral ini diharapkan selesai pada akhir tahun 2026.',
          sourceName: 'Reuters Business',
          author: 'Fintech Correspondent',
          url: 'https://www.reuters.com/business',
          urlToImage: 'https://images.unsplash.com/photo-1518186285589-2f7649de83e0?w=800',
          publishedAt: now.subtract(const Duration(hours: 16)).toIso8601String(),
          content: 'Indonesia memasuki era baru sistem pembayaran digital...',
        ),
        NewsArticle(
          title: 'Startup AgriTech Indonesia Raih Pendanaan Seri C 120 Juta Dollar dari SoftBank Vision Fund',
          description: 'Platform berbasis AI ini menghubungkan 2 juta petani langsung dengan pembeli korporasi, memotong perantara.',
          sourceName: 'TechCrunch',
          author: 'AgriTech Insider',
          url: 'https://techcrunch.com',
          urlToImage: 'https://images.unsplash.com/photo-1625246333195-78d9c38ad449?w=800',
          publishedAt: now.subtract(const Duration(days: 1, hours: 3)).toIso8601String(),
          content: 'Transformasi digital sektor pertanian Indonesia semakin meluas...',
        ),
        NewsArticle(
          title: 'OJK Resmi Larang Pinjaman Online Ilegal, 200+ Fintech Bodong Ditutup Dalam Sepekan',
          description: 'Regulasi baru ini menjadi langkah tegas pemerintah dalam melindungi konsumen dari praktik pinjaman tidak berizin.',
          sourceName: 'Kontan',
          author: 'Regulation Watch',
          url: 'https://www.kontan.co.id',
          urlToImage: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800',
          publishedAt: now.subtract(const Duration(days: 2)).toIso8601String(),
          content: 'Pembersihan industri fintech berizin terus berlanjut...',
        ),
        // Extra business articles for pagination
        NewsArticle(
          title: 'Indeks Harga Saham Gabungan Tembus 8.000 Poin untuk Pertama Kalinya dalam Sejarah',
          description: 'Optimisme investor terhadap pemulihan ekonomi pasca pandemi mendorong IHSG menembus level psikologis 8.000.',
          sourceName: 'Bisnis Indonesia',
          author: 'Market Watch',
          url: 'https://www.bisnis.com',
          urlToImage: 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=800',
          publishedAt: now.subtract(const Duration(hours: 3)).toIso8601String(),
          content: 'Pasar modal Indonesia mencatat rekor baru yang bersejarah...',
        ),
        NewsArticle(
          title: 'Jokowi Resmikan Proyek Kereta Cepat yang Menghubungkan Jakarta-Surabaya dalam 4 Jam',
          description: 'Proyek infrastruktur senilai Rp 200 triliun ini ditargetkan menjadi tulang punggung transportasi ekonomi Jawa.',
          sourceName: 'Kompas Ekonomi',
          author: 'Infrastructure Reporter',
          url: 'https://www.kompas.com',
          urlToImage: 'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=800',
          publishedAt: now.subtract(const Duration(hours: 8)).toIso8601String(),
          content: 'Konektivitas Jawa Timur-Jawa barat semakin terintegrasi...',
        ),
        NewsArticle(
          title: 'Nilai Tukar Rupiah Menguat ke Level Terkuat dalam 5 Tahun Terakhir',
          description: 'Kebijakan stabilisasi moneter dan surplus neraca perdagangan mendorong penguatan rupiah hingga 5%.',
          sourceName: 'Kontan Finance',
          author: 'Currency Analyst',
          url: 'https://www.kontan.co.id',
          urlToImage: 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=800',
          publishedAt: now.subtract(const Duration(hours: 12)).toIso8601String(),
          content: 'Penguatan rupiah menjadi sentimen positif bagi perekonomian nasional...',
        ),
        NewsArticle(
          title: 'Pertamina Temukan Cadangan Minyak Baru di Laut Jawa Setara 500 Juta Barel',
          description: 'Penemuan ini diproyeksikan dapat memenuhi kebutuhan energi nasional selama 10 tahun ke depan.',
          sourceName: 'Energy Today',
          author: 'Oil & Gas Reporter',
          url: 'https://www.energytoday.com',
          urlToImage: 'https://images.unsplash.com/photo-1518186285589-2f7649de83e0?w=800',
          publishedAt: now.subtract(const Duration(hours: 18)).toIso8601String(),
          content: 'Temuan ini mengurangi ketergantungan Indonesia pada impor minyak...',
        ),
        NewsArticle(
          title: 'Pariwisata Indonesia Raup Devisa Rp 500 Triliun di Tahun 2026, Lampaui Target',
          description: 'Kunjungan wisatawan mancanegara mencapai 25 juta orang berkat promosi Destinasi Super Prioritas.',
          sourceName: 'Travel Indonesia',
          author: 'Tourism Analyst',
          url: 'https://www.travelindonesia.com',
          urlToImage: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800',
          publishedAt: now.subtract(const Duration(days: 1)).toIso8601String(),
          content: 'Sektor pariwisata Indonesia pulih dan melesat...',
        ),
        NewsArticle(
          title: 'Shopee dan Lazada Bersaing Ketat di Program Belanja Online Nasional dengan Diskon hingga 90%',
          description: 'Persaingan e-commerce memanas dengan program diskon besar-besaran yang menguntungkan konsumen.',
          sourceName: 'E-Commerce Watch',
          author: 'Retail Analyst',
          url: 'https://www.ecommercewatch.com',
          urlToImage: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800',
          publishedAt: now.subtract(const Duration(days: 2)).toIso8601String(),
          content: 'Konsumen dimanjakan dengan berbagai promo belanja...',
        ),
        NewsArticle(
          title: 'Pemerintah Resmi Menurunkan Pajak Penghasilan Badan Usaha dari 22% Menjadi 18%',
          description: 'Kebijakan ini bertujuan menarik investasi asing dan meningkatkan daya saing industri dalam negeri.',
          sourceName: 'DDTC News',
          author: 'Tax Analyst',
          url: 'https://www.ddtc.co.id',
          urlToImage: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800',
          publishedAt: now.subtract(const Duration(days: 3)).toIso8601String(),
          content: 'Reformasi perpajakan terus berlanjut...',
        ),
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
        NewsArticle(
          title: 'Prabowo Subianto Produksi Film Sejarah Kerajaan Majapahit dengan Budget Rp 500 Miliar',
          description: 'Film epik yang disutradarai oleh sineas berkelas internasional ini dijadwalkan tayang Desember 2026.',
          sourceName: 'Liputan6 Hiburan',
          author: 'Entertainment Insider',
          url: 'https://www.liputan6.com',
          urlToImage: 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=800',
          publishedAt: now.subtract(const Duration(hours: 4)).toIso8601String(),
          content: 'Dunia perfilman Indonesia kedatangan mega proyek baru...',
        ),
        NewsArticle(
          title: 'TikTok Resmi Luncurkan Fitur Streaming Film Panjang, Netflix dan Disney+ Kehilangan Pelanggan',
          description: 'Platform short-video ini menambahkan katalog film panjang berkualitas bioskop dengan model langganan Rp 30.000/bulan.',
          sourceName: 'Variety',
          author: 'Streaming Insider',
          url: 'https://variety.com',
          urlToImage: 'https://images.unsplash.com/photo-1535016120720-40c646be5580?w=800',
          publishedAt: now.subtract(const Duration(hours: 7)).toIso8601String(),
          content: 'Persaingan industri streaming memasuki babak baru...',
        ),
        NewsArticle(
          title: 'AFF Cup 2026: Timnas Futsal Indonesia Cetak Sejarah ke Final Piala Dunia Futsal',
          description: 'Kemenangan dramatis adu penalti atas Thailand membawa Garuda ke turnamen futsal terbesar dunia untuk pertama kalinya.',
          sourceName: 'Goal.com',
          author: 'Futsal Reporter',
          url: 'https://www.goal.com',
          urlToImage: 'https://images.unsplash.com/photo-1551958219-acbc608c6377?w=800',
          publishedAt: now.subtract(const Duration(hours: 11)).toIso8601String(),
          content: 'Sejarah tercipta bagi futsal Indonesia...',
        ),
        NewsArticle(
          title: 'Aespa dan Blackpink Kolaborasi Spesial di Coachella 2026, Catat Rekor Penonton Tayangan Langsung',
          description: 'Kolaborasi sensasional ini menarik 80 juta penonton streaming secara serentak dari seluruh penjuru dunia.',
          sourceName: 'Billboard',
          author: 'K-Pop Correspondent',
          url: 'https://www.billboard.com',
          urlToImage: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800',
          publishedAt: now.subtract(const Duration(hours: 18)).toIso8601String(),
          content: 'Momen bersejarah dunia K-pop tercipta di padang pasir California...',
        ),
        NewsArticle(
          title: 'Raisa dan Isyana Sarasvati Kolaborasi Album Duet, Laris Manis 1 Juta Kopi dalam 24 Jam',
          description: 'Album bertajuk "Dua Sisi" ini memecahkan rekor penjualan album fisik tercepat di industri musik Indonesia.',
          sourceName: 'Rolling Stone Indonesia',
          author: 'Music Journalist',
          url: 'https://www.rollingstone.co.id',
          urlToImage: 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=800',
          publishedAt: now.subtract(const Duration(days: 1)).toIso8601String(),
          content: 'Dua diva Indonesia akhirnya bersatu dalam projek musikal...',
        ),
        NewsArticle(
          title: 'Serial Anime Adaptasi Novel Web Indonesia "Nusantara Online" Tayang Perdana di Crunchyroll',
          description: 'Novel populer karya penulis lokal ini diadaptasi menjadi anime 24 episode oleh studio Jepang MAPPA.',
          sourceName: 'Anime News Network',
          author: 'Anime Insider',
          url: 'https://www.animenewsnetwork.com',
          urlToImage: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800',
          publishedAt: now.subtract(const Duration(days: 2)).toIso8601String(),
          content: 'Industri kreatif Indonesia semakin Goes Global...',
        ),
        // Extra entertainment articles
        NewsArticle(
          title: 'Konser Dewa 19 Reunion Sukses Digelar di GBK, Dihadiri 100 Ribu Penggemar',
          description: 'Konser reuni band legendaris Indonesia ini menjadi salah satu konser terbesar dalam sejarah musik Tanah Air.',
          sourceName: 'Musik Kita',
          author: 'Music Fan',
          url: 'https://www.musikkita.com',
          urlToImage: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800',
          publishedAt: now.subtract(const Duration(hours: 4)).toIso8601String(),
          content: 'Stadion Utama Gelora Bung Karno dipenuhi puluhan ribu penggemar...',
        ),
        NewsArticle(
          title: 'Film Horor Indonesia "Pengabdi Setan 3" Raup 1 Triliun dalam Minggu Pertama',
          description: 'Film horor garapan sutradara Joko Anwar ini resmi menjadi film Indonesia terlaris sepanjang masa.',
          sourceName: 'Film Indonesia',
          author: 'Movie Buff',
          url: 'https://www.filmindonesia.co.id',
          urlToImage: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=800',
          publishedAt: now.subtract(const Duration(hours: 8)).toIso8601String(),
          content: 'Dunia perfilman Tanah Air kembali mencetak sejarah box office...',
        ),
        NewsArticle(
          title: 'Spotify Wrapped 2026: Taylor Swift Kembali Jadi Artis Paling Banyak Diputar di Indonesia',
          description: 'Berdasarkan data Spotify, musik pop internasional masih mendominasi tangga lagu di Indonesia.',
          sourceName: 'Spotify News',
          author: 'Music Data',
          url: 'https://www.spotify.com',
          urlToImage: 'https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=800',
          publishedAt: now.subtract(const Duration(hours: 16)).toIso8601String(),
          content: 'Tren mendengarkan musik di Indonesia terus berkembang...',
        ),
        NewsArticle(
          title: 'Netflix Produksi Series Original Indonesia Bertema Kolonial dengan Budget Rp 800 Miliar',
          description: 'Netflix mengumumkan produksi series termahal di Asia Tenggara yang akan tayang secara global tahun depan.',
          sourceName: 'Screen Daily',
          author: 'Streaming Reporter',
          url: 'https://www.screendaily.com',
          urlToImage: 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=800',
          publishedAt: now.subtract(const Duration(days: 1)).toIso8601String(),
          content: 'Indonesia semakin menjadi pusat produksi konten global...',
        ),
        NewsArticle(
          title: 'Festival Film Cannes 2026: Film Pendek Indonesia Masuk Nominasi Palme D\'Or',
          description: 'Film pendek karya sutradara muda Indonesia bersaing di kategori bergengsi festival film tertua di dunia.',
          sourceName: 'Cannes Daily',
          author: 'Film Critic',
          url: 'https://www.festival-cannes.com',
          urlToImage: 'https://images.unsplash.com/photo-1478720568477-152d9b164e26?w=800',
          publishedAt: now.subtract(const Duration(days: 2)).toIso8601String(),
          content: 'Karya anak bangsa kembali mengharumkan nama Indonesia...',
        ),
        NewsArticle(
          title: 'Game Online Lokal "Nusantara Royale" Tembus 50 Juta Unduhan Global',
          description: 'Game battle royale bertema mitologi Nusantara berhasil bersaing dengan PUBG Mobile dan Free Fire.',
          sourceName: 'Game Station',
          author: 'Gaming Guru',
          url: 'https://www.gamestation.com',
          urlToImage: 'https://images.unsplash.com/photo-1552820728-8b83bb6b10f7?w=800',
          publishedAt: now.subtract(const Duration(days: 2, hours: 10)).toIso8601String(),
          content: 'Industri game Indonesia berbicara di kancah global...',
        ),
        NewsArticle(
          title: 'Panggung Hiburan di IKN: Konser Musik Nusantara Digelar Perdana dengan Teknologi Hologram',
          description: 'Konser futuristik ini menampilkan penampilan hologram penyanyi legendaris yang telah tiada.',
          sourceName: 'Hiburan News',
          author: 'Entertainment Writer',
          url: 'https://www.hiburannews.com',
          urlToImage: 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800',
          publishedAt: now.subtract(const Duration(days: 3)).toIso8601String(),
          content: 'Perpaduan teknologi dan seni pertunjukan di Ibu Kota Negara...',
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
        NewsArticle(
          title: 'BPOM Resmi Setujui Obat Herbal Tradisional Indonesia untuk Pasar Farmasi Internasional',
          description: 'Ekstrak Jamu kunyit asam ini lolos uji klinis fase 2 dan akan dipasarkan di 30 negara melalui kerja sama dengan farmasi Eropa.',
          sourceName: 'Jurnal Kedokteran UI',
          author: 'Herbal Researcher',
          url: 'https://www.ui.ac.id',
          urlToImage: 'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?w=800',
          publishedAt: now.subtract(const Duration(hours: 5)).toIso8601String(),
          content: 'Warisan obat tradisional Indonesia mendapat pengakuan dunia...',
        ),
        NewsArticle(
          title: 'Peneliti ITS Ciptakan Alat Deteksi Dini Kanker Serviks Berbasis Smartphone dengan Akurasi 95%',
          description: 'Alat seharga Rp 500 ribu ini bisa digunakan oleh bidan di daerah terpencil tanpa perlu laboratorium canggih.',
          sourceName: 'Detik Health',
          author: 'Health Tech Reporter',
          url: 'https://health.detik.com',
          urlToImage: 'https://images.unsplash.com/photo-1559757175-5700dde675bc?w=800',
          publishedAt: now.subtract(const Duration(hours: 9)).toIso8601String(),
          content: 'Inovasi teknologi kesehatan dari kampus Indonesia...',
        ),
        NewsArticle(
          title: 'WHO Nyatakan Indonesia Bebas dari Wabah Demam Berdarah Stadium Tinggi untuk Pertama Kalinya',
          description: 'Program pemberantasan sarang nyamuk dan penggunaan Wolbachia terbukti efektif menekan kasus DBD hingga 90%.',
          sourceName: 'WHO SEARO',
          author: 'Public Health Expert',
          url: 'https://www.who.int/southeastasia',
          urlToImage: 'https://images.unsplash.com/photo-1584036561566-baf8f5f1b144?w=800',
          publishedAt: now.subtract(const Duration(hours: 14)).toIso8601String(),
          content: 'Prestasi luar biasa dalam bidang kesehatan masyarakat...',
        ),
        NewsArticle(
          title: 'Diet Mediterania Versi Indonesia: Ahli Gizi Unair Rancang Pola Makan Lokal yang Lebih Sehat',
          description: 'Modifikasi pola makan dengan bahan lokal seperti ikan, sayuran hijau, dan rempah menurunkan risiko penyakit jantung hingga 40%.',
          sourceName: 'Kompas Health',
          author: 'Nutrition Expert',
          url: 'https://health.kompas.com',
          urlToImage: 'https://images.unsplash.com/photo-1543362906-acfc16c67564?w=800',
          publishedAt: now.subtract(const Duration(hours: 20)).toIso8601String(),
          content: 'Pola makan sehat tidak harus mengikuti standar barat...',
        ),
        NewsArticle(
          title: 'RS Cipto Mangunkusumo Luncurkan Program Telemedicine Gratis untuk Masyarakat Pedesaan',
          description: 'Platform konsultasi dokter jarak jauh ini menjangkau 5.000 desa di 10 provinsi prioritas.',
          sourceName: 'Tribun Health',
          author: 'Digital Health Reporter',
          url: 'https://www.tribunnews.com',
          urlToImage: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=800',
          publishedAt: now.subtract(const Duration(days: 1, hours: 5)).toIso8601String(),
          content: 'Akses kesehatan semakin merata dengan teknologi...',
        ),
        NewsArticle(
          title: 'Ahli Gizi RS Pondok Indah Paparkan Bahaya Konsumsi Gula Berlebihan bagi Anak Usia Dini',
          description: 'Studi menunjukkan 70% anak Indonesia mengonsumsi gula tambahan melebihi batas aman WHO.',
          sourceName: 'Health.detik',
          author: 'Pediatric Nutritionist',
          url: 'https://health.detik.com',
          urlToImage: 'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=800',
          publishedAt: now.subtract(const Duration(days: 2)).toIso8601String(),
          content: 'Edukasi pola makan sehat untuk anak perlu dimulai sejak dini...',
        ),
        // Extra health articles
        NewsArticle(
          title: 'Kasus Demam Berdarah Menurun Drastis Berkat Nyamuk Wolbachia di 10 Kota Besar',
          description: 'Program penyebaran nyamuk Wolbachia berhasil menekan angka kasus DBD hingga lebih dari 80%.',
          sourceName: 'Kemenkes RI',
          author: 'Public Health',
          url: 'https://www.kemkes.go.id',
          urlToImage: 'https://images.unsplash.com/photo-1584036561566-baf8f5f1b144?w=800',
          publishedAt: now.subtract(const Duration(hours: 5)).toIso8601String(),
          content: 'Inovasi teknologi Wolbachia membuahkan hasil...',
        ),
        NewsArticle(
          title: 'Operasi Jantung Jarak Jauh Pertama Berhasil Dilakukan di Indonesia Menggunakan Robot 5G',
          description: 'Tim dokter RS Jantung dan Pembuluh Darah Harapan Kita berhasil melakukan operasi dari jarak 1.000 km.',
          sourceName: 'Medical News',
          author: 'Health Tech',
          url: 'https://www.medicalnews.com',
          urlToImage: 'https://images.unsplash.com/photo-1559757175-5700dde675bc?w=800',
          publishedAt: now.subtract(const Duration(hours: 10)).toIso8601String(),
          content: 'Teknologi 5G membawa revolusi di dunia kesehatan...',
        ),
        NewsArticle(
          title: 'Vaksin HPV Gratis untuk 20 Juta Remaja Putri Indonesia Mulai Digulirkan',
          description: 'Program vaksinasi massal ini menargetkan eliminasi kanker serviks di Indonesia pada tahun 2030.',
          sourceName: 'WHO Indonesia',
          author: 'Vaccine Program',
          url: 'https://www.who.int/indonesia',
          urlToImage: 'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=800',
          publishedAt: now.subtract(const Duration(hours: 15)).toIso8601String(),
          content: 'Langkah besar dalam pencegahan kanker serviks...',
        ),
        NewsArticle(
          title: 'Peneliti UGM Kembangkan Obat Kanker Payudara dari Bahan Alami Daun Sirsak',
          description: 'Uji klinis fase 2 menunjukkan tingkat keberhasilan 75% pada pasien kanker payudara stadium awal.',
          sourceName: 'UGM News',
          author: 'Medical Researcher',
          url: 'https://www.ugm.ac.id',
          urlToImage: 'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?w=800',
          publishedAt: now.subtract(const Duration(days: 1)).toIso8601String(),
          content: 'Penemuan obat herbal Indonesia kembali mengejutkan dunia medis...',
        ),
        NewsArticle(
          title: 'Polusi Udara Jakarta Menurun 40% Berkat Program Ganjil-Genap dan Hari Bebas Kendaraan',
          description: 'Kualitas udara ibu kota membaik signifikan berkat kebijakan transportasi yang lebih ketat dan ketat.',
          sourceName: 'Green Environment',
          author: 'Eco Reporter',
          url: 'https://www.greenenv.com',
          urlToImage: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800',
          publishedAt: now.subtract(const Duration(days: 1, hours: 8)).toIso8601String(),
          content: 'Warga Jakarta mulai menikmati udara yang lebih bersih...',
        ),
        NewsArticle(
          title: 'Studi Terbaru: Konsumsi Kopi Hitam Tanpa Gula Bisa Memperpanjang Usia Hingga 10 Tahun',
          description: 'Peneliti Harvard meneliti 100.000 responden selama 20 tahun menemukan korelasi positif antara kopi hitam dan umur panjang.',
          sourceName: 'Harvard Health',
          author: 'Longevity Researcher',
          url: 'https://www.health.harvard.edu',
          urlToImage: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
          publishedAt: now.subtract(const Duration(days: 2)).toIso8601String(),
          content: 'Kabar baik bagi para penikmat kopi hitam...',
        ),
        NewsArticle(
          title: 'Yoga dan Meditasi Terbukti Meningkatkan Daya Tahan Tubuh, Studi Universitas Indonesia',
          description: 'Penelitian menunjukkan praktik yoga rutin 3 kali seminggu meningkatkan sistem imun hingga 50%.',
          sourceName: 'UI News',
          author: 'Wellness Expert',
          url: 'https://www.ui.ac.id',
          urlToImage: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800',
          publishedAt: now.subtract(const Duration(days: 3)).toIso8601String(),
          content: 'Kesehatan holistik semakin terbukti manfaatnya...',
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
          title: 'Menteri Luar Negeri Dorong Kerja Sama ASEAN Hadapi Krisis Regional Myanmar',
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
        NewsArticle(
          title: 'Mahkamah Konstitusi Cabut UU Cipta Kerja Sebagian: Pekerja Minta Kenaikan Upah Minimum',
          description: 'Putusan MK menjadi pukulan bagi dunia usaha yang sudah menyiapkan rencana ekspansi besar-besaran di semester kedua.',
          sourceName: 'Reuters Indonesia',
          author: 'Legal Analyst',
          url: 'https://www.reuters.com',
          urlToImage: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800',
          publishedAt: now.subtract(const Duration(hours: 4)).toIso8601String(),
          content: 'Putusan MK mengguncang dunia usaha dan politik nasional...',
        ),
        NewsArticle(
          title: 'Indonesia Tandatangani Perjanjian Bebas Visa dengan 10 Negara Baru untuk Tingkatkan Diplomasi',
          description: 'Perjanjian ini mencakup negara-negara di Afrika dan Timur Tengah sebagai bagian dari diplomasi ekonomi.',
          sourceName: 'Jakarta Post',
          author: 'Foreign Affairs Reporter',
          url: 'https://www.thejakartapost.com',
          urlToImage: 'https://images.unsplash.com/photo-1541872703-74c5e44368f9?w=800',
          publishedAt: now.subtract(const Duration(hours: 10)).toIso8601String(),
          content: 'Ekspansi diplomatik Indonesia terus berlanjut...',
        ),
        NewsArticle(
          title: 'Gubernur DKI Jakarta Resmi Luncurkan Program Transaksi Nirkota Gratis untuk Warga Ibu Kota',
          description: 'Program subsidi transportasi publik ini menargetkan pengurangan kemacetan hingga 30% di area CBD Jakarta.',
          sourceName: 'Tribun News',
          author: 'Urban Policy Reporter',
          url: 'https://www.tribunnews.com',
          urlToImage: 'https://images.unsplash.com/photo-1555899434-94d1368aa7af?w=800',
          publishedAt: now.subtract(const Duration(hours: 15)).toIso8601String(),
          content: 'Kebijakan transportasi baru DKI Jakarta mulai berlaku minggu depan...',
        ),
        NewsArticle(
          title: 'DPR RI Setujui Anggaran Pemilu 2029 Sebesar Rp 50 Triliun untuk Modernisasi TPS Digital',
          description: 'Pemilu pertama di Indonesia yang menggunakan sistem e-voting di 50% TPS di seluruh wilayah.',
          sourceName: 'CNN Indonesia',
          author: 'Parliament Reporter',
          url: 'https://www.cnnindonesia.com',
          urlToImage: 'https://images.unsplash.com/photo-1540910419892-4a36d2c3266c?w=800',
          publishedAt: now.subtract(const Duration(days: 1, hours: 8)).toIso8601String(),
          content: 'Modernisasi sistem pemilihan umum memasuki fase baru...',
        ),
        NewsArticle(
          title: 'Presiden Resmikan IKN Nusantara sebagai Ibu Kota Baru, Operasi Pemerintahan Dimulai Agustus',
          description: 'Seluruh kementerian dan lembaga negara dijadwalkan berpindah operasi ke IKN pada awal Agustus mendatang.',
          sourceName: 'Antara News',
          author: 'Capital City Reporter',
          url: 'https://www.antaranews.com',
          urlToImage: 'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=800',
          publishedAt: now.subtract(const Duration(days: 2)).toIso8601String(),
          content: 'Sejarah baru ibu kota Indonesia resmi dimulai...',
        ),
        // Extra politics articles
        NewsArticle(
          title: 'KPK Tangkap Bupati dan 10 Anggota DPRD dalam Operasi Tangkap Tangan Suap Proyek Infrastruktur',
          description: 'Operasi senyap yang dilakukan dini hari ini berhasil mengamankan uang tunai miliaran rupiah dari berbagai lokasi.',
          sourceName: 'KPK News',
          author: 'Anti-Corruption',
          url: 'https://www.kpk.go.id',
          urlToImage: 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=800',
          publishedAt: now.subtract(const Duration(hours: 2)).toIso8601String(),
          content: 'KPK kembali menunjukkan komitmennya dalam pemberantasan korupsi...',
        ),
        NewsArticle(
          title: 'DPR dan Pemerintah Setujui RUU Perlindungan Pekerja Migran Indonesia',
          description: 'UU baru ini memberikan perlindungan lebih ketat bagi PMI di luar negeri termasuk jaminan hukum dan sosial.',
          sourceName: 'DPR RI',
          author: 'Parliament Reporter',
          url: 'https://www.dpr.go.id',
          urlToImage: 'https://images.unsplash.com/photo-1529543544282-ea114074bc5e?w=800',
          publishedAt: now.subtract(const Duration(hours: 6)).toIso8601String(),
          content: 'Pekerja migran Indonesia mendapat angin segar...',
        ),
        NewsArticle(
          title: 'Indonesia dan Malaysia Sepakat Selesaikan Sengketa Perbatasan Laut Secara Damai',
          description: 'Kedua negara sepakat membentuk tim negosiasi bersama untuk menyelesaikan sengketa yang telah berlangsung puluhan tahun.',
          sourceName: 'Kemlu RI',
          author: 'Diplomatic Corps',
          url: 'https://www.kemlu.go.id',
          urlToImage: 'https://images.unsplash.com/photo-1559827291-baf8f0f60cef?w=800',
          publishedAt: now.subtract(const Duration(hours: 10)).toIso8601String(),
          content: 'Diplomasi damai menjadi pilihan kedua negara tetangga...',
        ),
        NewsArticle(
          title: 'Menteri Pertanian Luncurkan Program Swasembada Pangan 2028, Target Berhenti Impor Beras',
          description: 'Program cetak sawah baru seluas 1 juta hektar di Kalimantan dan Papua dicanangkan pemerintah.',
          sourceName: 'Kementan',
          author: 'Agriculture Reporter',
          url: 'https://www.pertanian.go.id',
          urlToImage: 'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=800',
          publishedAt: now.subtract(const Duration(hours: 14)).toIso8601String(),
          content: 'Target swasembada pangan nasional dipercepat...',
        ),
        NewsArticle(
          title: 'DPD RI Usulkan Sistem Presidensial Dua Periode dengan Masa Jabatan 7 Tahun',
          description: 'Usulan amendemen UUD 1945 ini menjadi perdebatan hangat di kalangan politisi dan akademisi hukum tata negara.',
          sourceName: 'CNN Indonesia',
          author: 'Constitutional Expert',
          url: 'https://www.cnnindonesia.com',
          urlToImage: 'https://images.unsplash.com/photo-1540910419892-4a36d2c3266c?w=800',
          publishedAt: now.subtract(const Duration(days: 1)).toIso8601String(),
          content: 'Wacana amendemen UUD kembali mengemuka...',
        ),
        NewsArticle(
          title: 'Pemerintah Tetapkan 1 Syawal 1448 H Berdasarkan Hasil Sidang Isbat',
          description: 'Keputusan bersama antara pemerintah, ormas Islam, dan ahli astronomi menetapkan hari raya secara nasional.',
          sourceName: 'Kemenag RI',
          author: 'Religious Affairs',
          url: 'https://www.kemenag.go.id',
          urlToImage: 'https://images.unsplash.com/photo-1532629345422-7515f3d16bb6?w=800',
          publishedAt: now.subtract(const Duration(days: 1, hours: 12)).toIso8601String(),
          content: 'Sidang Isbat berlangsung khidmat di Kementerian Agama...',
        ),
        NewsArticle(
          title: 'Rekomendasi BPK: Negara Berpotensi Rugi Rp 70 Triliun Akibat Lemahnya Pengawasan Keuangan Daerah',
          description: 'Laporan Badan Pemeriksa Keuangan menyoroti lemahnya tata kelola keuangan di 250 pemerintah daerah.',
          sourceName: 'BPK RI',
          author: 'Auditor',
          url: 'https://www.bpk.go.id',
          urlToImage: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800',
          publishedAt: now.subtract(const Duration(days: 2)).toIso8601String(),
          content: 'Temuan BPK menjadi perhatian serius pemerintah pusat...',
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
    final List<NewsArticle> allArticles = [];
    allArticles.addAll(_getMockHeadlines('sports', 1, 50));
    allArticles.addAll(_getMockHeadlines('technology', 1, 50));
    allArticles.addAll(_getMockHeadlines('business', 1, 50));
    allArticles.addAll(_getMockHeadlines('entertainment', 1, 50));
    allArticles.addAll(_getMockHeadlines('health', 1, 50));
    allArticles.addAll(_getMockHeadlines('politics', 1, 50));

    final lowerQuery = query.toLowerCase();
    final filteredArticles = allArticles.where((article) {
      return article.title.toLowerCase().contains(lowerQuery) ||
             (article.description?.toLowerCase().contains(lowerQuery) ?? false) ||
             (article.sourceName?.toLowerCase().contains(lowerQuery) ?? false) ||
             (article.author?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();

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
