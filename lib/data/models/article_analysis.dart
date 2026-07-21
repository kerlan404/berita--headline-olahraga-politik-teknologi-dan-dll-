/// Model untuk hasil analisis artikel oleh Editor Berita Senior REEDFEED.
///
/// Struktur ini sesuai format JSON yang digunakan oleh sistem analisis:
/// - judul_saran: Judul singkat dan lugas
/// - inti_berita: Ringkasan komprehensif (3-4 kalimat)
/// - poin_kunci: Daftar fakta penting dalam format 5W+1H
class ArticleAnalysis {
  final String judulSaran;
  final String intiBerita;
  final List<String> poinKunci;

  const ArticleAnalysis({
    required this.judulSaran,
    required this.intiBerita,
    required this.poinKunci,
  });

  factory ArticleAnalysis.fromJson(Map<String, dynamic> json) {
    return ArticleAnalysis(
      judulSaran: json['judul_saran'] as String? ?? '',
      intiBerita: json['inti_berita'] as String? ?? '',
      poinKunci: (json['poin_kunci'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judul_saran': judulSaran,
      'inti_berita': intiBerita,
      'poin_kunci': poinKunci,
    };
  }
}
