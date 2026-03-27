class PatchNote {
  final String version;
  final String date;
  final String title;
  final List<String> content;
  final DateTime releaseDate;

  PatchNote({
    required this.version,
    required this.date,
    required this.title,
    required this.content,
    required this.releaseDate,
  });
}
