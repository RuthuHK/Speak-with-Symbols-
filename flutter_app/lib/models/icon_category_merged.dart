import 'icon_item.dart';

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

  Map<String, dynamic> toJson() => {
    'category': category,
    'image': image,
    'items': items.map((item) => item.toJson()).toList(),
  };
}
