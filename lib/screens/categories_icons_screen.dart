import 'package:flutter/material.dart';
import '../models/icon_category.dart';

class CategoryIconsScreen extends StatefulWidget {
  final IconCategory category;

  const CategoryIconsScreen({required this.category});

  @override
  _CategoryIconsScreenState createState() => _CategoryIconsScreenState();
}

class _CategoryIconsScreenState extends State<CategoryIconsScreen> {
  List<String> selectedWords = [];

  void toggleSelection(String word) {
    setState(() {
      if (selectedWords.contains(word)) {
        selectedWords.remove(word);
      } else {
        selectedWords.add(word);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.category)),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: widget.category.items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final icon = widget.category.items[index];
          final isSelected = selectedWords.contains(icon.word);

          return GestureDetector(
            onTap: () => toggleSelection(icon.word),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFFCF7FF),
                border: Border.all(
                  color: isSelected ? Colors.green : Colors.grey.shade400,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(icon.image, fit: BoxFit.contain),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      icon.word,
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
