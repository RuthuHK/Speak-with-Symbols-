import 'package:flutter/material.dart';
import '../models/icon_category.dart';

class IconScreen extends StatelessWidget {
  final IconCategory category;
  const IconScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.category)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: category.items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final iconItem = category.items[index];
          return Column(
            children: [
              Image.asset(iconItem.image, width: 50, height: 50),
              const SizedBox(height: 4),
              Text(
                iconItem.word,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }
}
