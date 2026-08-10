class IconItem {
  final String word;
  final String image;
  final String? name;
  final String? desc;
  final List<double>? embedding;

  IconItem({
    required this.word,
    required this.image,
    this.name,
    this.desc,
    this.embedding,
  });

  factory IconItem.fromJson(Map<String, dynamic> json) {
    return IconItem(
      word: json['word'] ?? '',
      image: json['image'] ?? '',
      name: json['name'],
      desc: json['desc'],
      embedding: json['embedding'] != null
          ? List<double>.from(
              (json['embedding'] as List).map((e) => (e as num).toDouble()),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'word': word,
    'image': image,
    if (name != null) 'name': name,
    if (desc != null) 'desc': desc,
    if (embedding != null) 'embedding': embedding,
  };
}
