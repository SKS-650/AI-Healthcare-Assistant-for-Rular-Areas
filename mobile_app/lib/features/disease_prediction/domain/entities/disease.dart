class Disease {
  final String id;
  final String name;
  final String shortDescription;
  final String overview;
  final List<String> symptoms;
  final List<String> causes;
  final String imageUrl;

  const Disease({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.overview,
    required this.symptoms,
    required this.causes,
    required this.imageUrl,
  });
}
