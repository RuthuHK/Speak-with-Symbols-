// lib/models/icon_item.dart
class IconItem {
  final String name;
  final String iconUrl;

  IconItem({required this.name, required this.iconUrl});

  factory IconItem.fromJson(Map<String, dynamic> json) {
    return IconItem(name: json['name'] ?? '', iconUrl: json['iconUrl'] ?? '');
  }
}
