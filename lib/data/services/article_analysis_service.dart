import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/article_analysis.dart';
import '../models/news_article.dart';

/// Service analisis artikel untuk REEDSFEED.
///
/// Berperan sebagai "API endpoint" yang menerima teks artikel dan
/// mengembalikan analisis terstruktur (judul, inti, poin kunci).
///
/// ## Mode Operasi:
/// 1. **AI API Mode** — Kirim teks ke OpenAI-compatible API untuk analisis cerdas
///    (aktif jika `OPENAI_API_KEY` terisi di .env)
/// 2. **Local Engine Mode** — Analisis otomatis dari data artikel yang ada
///    (fallback jika API key tidak tersedia)
class ArticleAnalysisService {
  final http.Client _client;

  ArticleAnalysisService({http.Client? client}) : _client = client ?? http.Client();

  /// API key untuk OpenAI-compatible API (dari .env)
  String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  /// Base URL untuk OpenAI-compatible API (dari .env)
  String get _apiBaseUrl =>
      dotenv.env['OPENAI_BASE_URL'] ?? 'https://api.openai.com/v1';

  /// Model AI yang digunakan (dari .env)
  String get _model =>
      dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini';

  /// Apakah mode AI API aktif
  bool get isAiMode => _apiKey.isNotEmpty;

  /// Analisis artikel dari objek [NewsArticle].
  ///
  /// Menggabungkan title, description, dan content sebagai teks sumber,
  /// lalu mengirimkannya ke sistem analisis.
  Future<ArticleAnalysis> analyze(NewsArticle article) async {
    final sourceText = _buildSourceText(article);

    if (isAiMode) {
      return _analyzeWithAi(sourceText);
    }

    return _analyzeLocally(article);
  }

  /// Analisis artikel dari teks mentah.
  ///
  /// Method ini adalah "API endpoint" utama — menerima teks artikel
  /// dan mengembalikan [ArticleAnalysis] terstruktur.
  Future<ArticleAnalysis> analyzeText(String sourceText,
      {String? title}) async {
    if (isAiMode) {
      return _analyzeWithAi(sourceText);
    }

    return _analyzeTextLocally(sourceText, title: title);
  }

  /// Bangun teks sumber dari data artikel
  String _buildSourceText(NewsArticle article) {
    final buffer = StringBuffer();
    buffer.writeln('Judul: ${article.title}');
    if (article.description != null && article.description!.isNotEmpty) {
      buffer.writeln('Deskripsi: ${article.description}');
    }
    if (article.content != null && article.content!.isNotEmpty) {
      buffer.writeln('Konten: ${article.content}');
    }
    if (article.author != null && article.author!.isNotEmpty) {
      buffer.writeln('Penulis: ${article.author}');
    }
    buffer.writeln('Sumber: ${article.sourceName ?? 'Tidak diketahui'}');
    return buffer.toString();
  }

  // ──────────────────────────────────────────────
  // AI API Mode — OpenAI Chat Completions API
  // ──────────────────────────────────────────────

  Future<ArticleAnalysis> _analyzeWithAi(String sourceText) async {
    try {
      final url = Uri.parse('$_apiBaseUrl/chat/completions');

      // System prompt — instruksi untuk AI sebagai Editor Berita Senior REEDFEED
      final systemPrompt = '''
Anda adalah Editor Berita Senior untuk platform bernama REEDFEED. 
Tugas Anda adalah menganalisis teks artikel berita dan mengekstrak "inti informasi" yang padat, jelas, dan komprehensif.

Instruksi Ekstraksi:
1. Hindari basa-basi dan opini penulis.
2. Buat ringkasan 2-3 paragraf pendek yang mencakup unsur 5W+1H.
3. Gunakan bahasa Indonesia yang baku, jurnalistik, netral.
4. Jangan mengubah fakta atau menambahkan informasi di luar teks.

Format output: Kembalikan JSON VALID tanpa markdown formatting, persis seperti ini:
{
  "judul_saran": "Judul singkat dan lugas berdasarkan isi berita",
  "inti_berita": "Ringkasan komprehensif 3-4 kalimat yang menjelaskan kejadian utama",
  "poin_kunci": [
    "Poin fakta ke-1",
    "Poin fakta ke-2",
    "Poin fakta ke-3"
  ]
}
''';

      final response = await _client
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: json.encode({
              'model': _model,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': 'Teks Artikel Sumber:\n\n$sourceText'},
              ],
              'temperature': 0.3,
              'max_tokens': 1024,
              'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final choices = data['choices'] as List;
        if (choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>;
          final content = message['content'] as String;

          // Parse JSON dari response
          try {
            final analysisJson = json.decode(content) as Map<String, dynamic>;
            return ArticleAnalysis.fromJson(analysisJson);
          } catch (e) {
            debugPrint('ArticleAnalysisService: Failed to parse AI JSON — $e');
            debugPrint('Raw AI response: $content');
            // Coba ekstrak JSON dari string
            final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
            if (jsonMatch != null) {
              final analysisJson = json.decode(jsonMatch.group(0)!);
              return ArticleAnalysis.fromJson(analysisJson as Map<String, dynamic>);
            }
            throw FormatException('Could not parse AI response as JSON');
          }
        }
        throw Exception('No choices in AI response');
      } else {
        debugPrint(
            'ArticleAnalysisService: API error ${response.statusCode} — falling back to local engine');
        throw Exception('Gagal menganalisis artikel (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('ArticleAnalysisService: AI unavailable — using local engine');
      // Fallback ke local engine jika AI gagal
      return _analyzeTextLocally(sourceText);
    }
  }

  // ──────────────────────────────────────────────
  // Local Engine Mode — analisis dari data artikel
  // ──────────────────────────────────────────────

  /// Local analysis engine — mengekstrak inti berita dari [NewsArticle]
  Future<ArticleAnalysis> _analyzeLocally(NewsArticle article) async {
    // Simulasi delay untuk UX (seperti loading dari API)
    await Future.delayed(const Duration(milliseconds: 400));

    final title = article.title;
    final description = article.description ?? '';
    final content = article.content ?? '';

    return _buildLocalAnalysis(title, description, content,
        sourceName: article.sourceName);
  }

  /// Local analysis engine — dari teks mentah
  Future<ArticleAnalysis> _analyzeTextLocally(String sourceText,
      {String? title}) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // Parse teks untuk ekstraksi
    final lines = sourceText.split('\n');
    final extractedTitle = title ?? lines.firstWhere(
        (l) => l.startsWith('Judul:'),
        orElse: () => '');
    final cleanTitle = extractedTitle.replaceFirst('Judul: ', '');
    final description = lines
        .firstWhere((l) => l.startsWith('Deskripsi:'),
            orElse: () => '')
        .replaceFirst('Deskripsi: ', '');
    final content = lines
        .firstWhere((l) => l.startsWith('Konten:'),
            orElse: () => '')
        .replaceFirst('Konten: ', '');

    return _buildLocalAnalysis(cleanTitle, description, content);
  }

  /// Local analysis engine inti — ekstraksi 5W+1H
  ArticleAnalysis _buildLocalAnalysis(
    String title,
    String description,
    String content, {
    String? sourceName,
  }) {
    // Judul saran — gunakan judul asli, bersihkan dari clickbait
    final judulSaran = _cleanTitle(title);

    // Inti berita — gabungan deskripsi + 2 kalimat pertama konten
    final intiBerita = _buildIntiBerita(description, content);

    // Poin kunci — ekstrak 5W+1H dari data yang tersedia
    final poinKunci = _extractPoinKunci(title, description, content, sourceName);

    return ArticleAnalysis(
      judulSaran: judulSaran,
      intiBerita: intiBerita,
      poinKunci: poinKunci,
    );
  }

  /// Bersihkan judul dari elemen clickbait
  String _cleanTitle(String title) {
    // Hapus tanda seru berlebihan, all-caps yang tidak perlu
    var clean = title
        .replaceAll(RegExp(r'!{2,}'), '!')
        .replaceAll(RegExp(r'\?{2,}'), '?')
        .trim();

    // Batasi panjang
    if (clean.length > 120) {
      clean = '${clean.substring(0, 117)}...';
    }

    return clean;
  }

  /// Bangun inti berita dari deskripsi dan konten
  String _buildIntiBerita(String description, String content) {
    final parts = <String>[];

    // Ambil deskripsi sebagai kalimat pembuka
    if (description.isNotEmpty) {
      parts.add(description.trim());
    }

    // Ambil 1-2 kalimat pertama dari konten
    if (content.isNotEmpty) {
      final sentences = content
          .split(RegExp(r'(?<=[.!?])\s+'))
          .where((s) => s.trim().isNotEmpty)
          .take(2)
          .map((s) => s.trim())
          .toList();
      parts.addAll(sentences);
    }

    if (parts.isEmpty) {
      return 'Berita ini sedang dalam proses analisis. Silakan baca selengkapnya untuk informasi lebih lanjut.';
    }

    return parts.join(' ');
  }

  /// Ekstrak poin kunci dalam format 5W+1H
  List<String> _extractPoinKunci(
    String title,
    String description,
    String content,
    String? sourceName,
  ) {
    final poin = <String>[];
    final text = '$title $description $content';

    // WHAT — apa yang terjadi? (dari judul/deskripsi)
    final what = title.isNotEmpty ? title : description;
    if (what.isNotEmpty) {
      poin.add(what);
    }

    // WHO — siapa yang terlibat? (cari nama organisasi/tokoh)
    if (sourceName != null && sourceName.isNotEmpty) {
      poin.add('Sumber: $sourceName');
    }

    // WHEN — kapan? (ambil info waktu jika ada)
    final timePatterns = [
      RegExp(r'(hari ini|kemarin|(?:senin|selasa|rabu|kamis|jumat|sabtu|minggu))',
          caseSensitive: false),
      RegExp(r'(\d+\s+(?:januari|februari|maret|april|mei|juni|juli|agustus|september|oktober|november|desember))',
          caseSensitive: false),
      RegExp(r'(tahun\s+\d{4})', caseSensitive: false),
    ];
    for (final pattern in timePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        poin.add('Waktu: ${match.group(1)}');
        break;
      }
    }

    // WHY — mengapa? (ambil kalimat yang mengandung alasan)
    final whyPatterns = [
      RegExp(r'(bertujuan|untuk|sebab|karena|guna|dalam rangka)',
          caseSensitive: false),
    ];
    for (final pattern in whyPatterns) {
      final match = pattern.firstMatch(description);
      if (match != null && description.isNotEmpty) {
        final index = description.indexOf(match.group(1)!);
        if (index >= 0) {
          poin.add(description.substring(index, description.length).trim());
        }
        break;
      }
    }

    // Dampak / kutipan penting (dari konten)
    if (content.isNotEmpty) {
      final sentences = content.split(RegExp(r'(?<=[.!?])\s+'));
      for (final sentence in sentences.take(3)) {
        final impactPatterns = [
          'mengakibatkan',
          'berdampak',
          'menurut',
          'menekankan',
          'mengungkapkan',
        ];
        if (impactPatterns.any((p) => sentence.toLowerCase().contains(p))) {
          poin.add(sentence.trim());
          break;
        }
      }
    }

    // Batasi maksimal 5 poin, minimal 3
    if (poin.length > 5) poin.removeRange(3, poin.length);
    while (poin.length < 3) {
      poin.add('Baca artikel selengkapnya untuk informasi lebih detail.');
      if (poin.length >= 3) break;
    }

    return poin;
  }
}
