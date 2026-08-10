// class IconItem {
//   final String word;
//   final String image;

//   IconItem({required this.word, required this.image});

//   factory IconItem.fromJson(Map<String, dynamic> json) {
//     return IconItem(word: json['word'] ?? '', image: json['image'] ?? '');
//   }
// }

// class IconCategory {
//   final String category;
//   final String image;
//   final List<IconItem> items;

//   IconCategory({
//     required this.category,
//     required this.image,
//     required this.items,
//   });

//   factory IconCategory.fromJson(Map<String, dynamic> json) {
//     return IconCategory(
//       category: json['category'] ?? '',
//       image: json['image'] ?? '',
//       items: (json['items'] as List)
//           .map((item) => IconItem.fromJson(item))
//           .toList(),
//     );
//   }
// }

class IconItem {
  final String word;
  final String image;

  IconItem({required this.word, required this.image});

  factory IconItem.fromJson(Map<String, dynamic> json) {
    return IconItem(word: json['word'] ?? '', image: json['image'] ?? '');
  }
}

class IconCategory {
  final String category;
  final String image;
  final List<IconItem> items;

  IconCategory({
    required this.category,
    required this.image,
    required this.items,
  });

  factory IconCategory.fromJson(Map<String, dynamic> json) {
    return IconCategory(
      category: json['category'] ?? '',
      image: json['image'] ?? '',
      items: (json['items'] as List)
          .map((item) => IconItem.fromJson(item))
          .toList(),
    );
  }
}
