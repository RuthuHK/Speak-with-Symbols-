// // lib/screens/home_screen.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import '../models/icon_category.dart';
// import '../services/sentence_service.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   List<IconCategory> categories = [];
//   List<String> selectedWords = [];
//   String generatedSentence = '';
//   final FlutterTts flutterTts = FlutterTts();

//   @override
//   void initState() {
//     super.initState();
//     loadIconData();
//   }

//   Future<void> loadIconData() async {
//     final String jsonString =
//         await rootBundle.loadString('assets/icon_categories.json');
//     final List<dynamic> jsonList = jsonDecode(jsonString);

//     setState(() {
//       categories = jsonList
//           .map((category) => IconCategory.fromJson(category))
//           .toList();
//     });
//   }

//   void toggleSelection(String word) {
//     setState(() {
//       if (selectedWords.contains(word)) {
//         selectedWords.remove(word);
//       } else {
//         selectedWords.add(word);
//       }
//     });
//   }

//   Future<void> generateSentenceFromSelected() async {
//     if (selectedWords.isEmpty) return;
//     final sentence = await generateSentence(selectedWords);
//     setState(() {
//       generatedSentence = sentence;
//     });
//   }

//   Future<void> speakSentence(String sentence) async {
//     await flutterTts.setLanguage("en-US");
//     await flutterTts.setSpeechRate(0.5);
//     await flutterTts.speak(sentence);
//   }

//   Future<void> showTranslation(String langCode, String title) async {
//     final translated = await translateText(generatedSentence, langCode);
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(title),
//         content: Text(translated),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("Close"),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("🧠 Icon Sentence Generator")),
//       body: categories.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : ListView(
//               children: categories.map((category) {
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding:
//                           const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       child: Text(category.category,
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold)),
//                     ),
//                     GridView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       padding: EdgeInsets.symmetric(horizontal: 12),
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 4,
//                           mainAxisSpacing: 8,
//                           crossAxisSpacing: 8),
//                       itemCount: category.items.length,
//                       itemBuilder: (context, index) {
//                         final icon = category.items[index];
//                         final isSelected = selectedWords.contains(icon.word);
//                         return GestureDetector(
//                           onTap: () => toggleSelection(icon.word),
//                           child: Container(
//                             padding: EdgeInsets.all(6),
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                   color: isSelected
//                                       ? Colors.green
//                                       : Colors.grey.shade400,
//                                   width: 2),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Column(
//                               children: [
//                                 Expanded(
//                                   child: Image.asset(icon.image),
//                                 ),
//                                 Text(icon.word,
//                                     style: TextStyle(fontSize: 12),
//                                     textAlign: TextAlign.center),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     SizedBox(height: 10),
//                   ],
//                 );
//               }).toList(),
//             ),
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (generatedSentence.isNotEmpty)
//                 Column(
//                   children: [
//                     Text(
//                       "💬 $generatedSentence",
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 10),
//                   ],
//                 )
//               else
//                 Column(
//                   children: [
//                     Text(
//                       "💬 No sentence generated yet.",
//                       style: TextStyle(fontSize: 15, color: Colors.grey),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 10),
//                   ],
//                 ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: generateSentenceFromSelected,
//                     icon: Icon(Icons.auto_fix_high),
//                     label: Text("Generate"),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: generatedSentence.isNotEmpty
//                         ? () => speakSentence(generatedSentence)
//                         : null,
//                     icon: Icon(Icons.volume_up),
//                     label: Text("Speak"),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: generatedSentence.isNotEmpty
//                         ? () => showTranslation("hi", "Hindi Translation")
//                         : null,
//                     child: Text("Translate to Hindi"),
//                   ),
//                   ElevatedButton(
//                     onPressed: generatedSentence.isNotEmpty
//                         ? () => showTranslation("kn", "Kannada Translation")
//                         : null,
//                     child: Text("Translate to Kannada"),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// Future<void> generateSentenceFromSelected() async {
//   final sentence = await generateSentence(selectedWords);
//   setState(() {
//     generatedSentence = sentence;
//   });
// }

// // lib/screens/home_screen.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import '../models/icon_category.dart';
// import '../services/sentence_service.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String? selectedCategory; // currently selected category
//   List<IconCategory> categories = [];
//   List<String> selectedWords = [];
//   String generatedSentence = '';
//   final FlutterTts flutterTts = FlutterTts();

//   @override
//   void initState() {
//     super.initState();
//     loadIconData();
//   }

//   Future<void> loadIconData() async {
//     final String jsonString =
//         await rootBundle.loadString('assets/icon_categories.json');
//     final List<dynamic> jsonList = jsonDecode(jsonString);

//     setState(() {
//       categories = jsonList
//           .map((category) => IconCategory.fromJson(category))
//           .toList();
//     });
//   }

//   void toggleSelection(String word) {
//     setState(() {
//       if (selectedWords.contains(word)) {
//         selectedWords.remove(word);
//       } else {
//         selectedWords.add(word);
//       }
//     });
//   }

//   Future<void> generateSentenceFromSelected() async {
//     if (selectedWords.isEmpty) return;

//     try {
//       final sentence = await generateSentence(selectedWords);
//       print('✅ Sentence set in state: $sentence');
//       setState(() {
//         generatedSentence = sentence;
//       });
//     } catch (e) {
//       print('❌ Error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text("Failed to generate sentence"),
//       ));
//     }
//   }

//   Future<void> speakSentence(String sentence) async {
//     await flutterTts.setLanguage("en-US");
//     await flutterTts.setSpeechRate(0.5);
//     await flutterTts.speak(sentence);
//   }

//   Future<void> showTranslation(String langCode, String title) async {
//     try {
//       final translated = await translateText(generatedSentence, langCode);
//       showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: Text(title),
//           content: Text(translated),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("Close"),
//             )
//           ],
//         ),
//       );
//     } catch (e) {
//       print("❌ Translation failed: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("🧠 Icon Sentence Generator")),
//       body: categories.isEmpty
//     ? Center(child: CircularProgressIndicator())
//     : Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: DropdownButton<String>(
//               value: selectedCategory,
//               isExpanded: true,
//               hint: Text("Select Category"),
//               items: categories.map((category) {
//                 return DropdownMenuItem<String>(
//                   value: category.category,
//                   child: Text(category.category),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedCategory = value;
//                 });
//               },
//             ),
//           ),
//           if (selectedCategory != null)
//             Expanded(
//               child: GridView.builder(
//                 padding: EdgeInsets.symmetric(horizontal: 12),
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 4,
//                     mainAxisSpacing: 8,
//                     crossAxisSpacing: 8),
//                 itemCount: categories
//                     .firstWhere((cat) => cat.category == selectedCategory)
//                     .items
//                     .length,
//                 itemBuilder: (context, index) {
//                   final selectedCat = categories.firstWhere(
//                       (cat) => cat.category == selectedCategory);
//                   final icon = selectedCat.items[index];
//                   final isSelected = selectedWords.contains(icon.word);
//                   return GestureDetector(
//                     onTap: () => toggleSelection(icon.word),
//                     child: Container(
//                       padding: EdgeInsets.all(6),
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                             color: isSelected
//                                 ? Colors.green
//                                 : Colors.grey.shade400,
//                             width: 2),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         children: [
//                           Expanded(
//                             child: Image.asset(icon.image),
//                           ),
//                           Text(icon.word,
//                               style: TextStyle(fontSize: 12),
//                               textAlign: TextAlign.center),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           if (selectedCategory == null)
//             Padding(
//               padding: const EdgeInsets.only(top: 24.0),
//               child: Text(
//                 "⬆️ Select a category to view icons",
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             ),
//         ],
//       ),
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (generatedSentence.isNotEmpty)
//                 Column(
//                   children: [
//                     Text(
//                       "💬 $generatedSentence",
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 10),
//                   ],
//                 )
//               else
//                 Column(
//                   children: [
//                     Text(
//                       "💬 No sentence generated yet.",
//                       style: TextStyle(fontSize: 15, color: Colors.grey),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 10),
//                   ],
//                 ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: generateSentenceFromSelected,
//                     icon: Icon(Icons.auto_fix_high),
//                     label: Text("Generate"),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: generatedSentence.isNotEmpty
//                         ? () => speakSentence(generatedSentence)
//                         : null,
//                     icon: Icon(Icons.volume_up),
//                     label: Text("Speak"),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: generatedSentence.isNotEmpty
//                         ? () => showTranslation("hi", "Hindi Translation")
//                         : null,
//                     child: Text("Translate to Hindi"),
//                   ),
//                   ElevatedButton(
//                     onPressed: generatedSentence.isNotEmpty
//                         ? () => showTranslation("kn", "Kannada Translation")
//                         : null,
//                     child: Text("Translate to Kannada"),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//////////////////////////////////////////////////////////////////////

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import '../models/icon_category.dart';
// import '../services/sentence_service.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   List<IconCategory> categories = [];
//   List<String> selectedWords = [];
//   String generatedSentence = '';
//   String translatedHindi = '';
//   String translatedKannada = '';
//   String? selectedCategory;
//   final FlutterTts flutterTts = FlutterTts();

//   @override
//   void initState() {
//     super.initState();
//     loadIconData();
//   }

//   Future<void> loadIconData() async {
//     final String jsonString =
//         await rootBundle.loadString('assets/icon_categories.json');
//     final List<dynamic> jsonList = jsonDecode(jsonString);

//     setState(() {
//       categories = jsonList
//           .map((category) => IconCategory.fromJson(category))
//           .toList();
//     });
//   }

//   void toggleSelection(String word) {
//     setState(() {
//       if (selectedWords.contains(word)) {
//         selectedWords.remove(word);
//       } else {
//         selectedWords.add(word);
//       }
//     });
//   }

//   Future<void> generateSentenceFromSelected() async {
//     if (selectedWords.isEmpty) return;

//     try {
//       final sentence = await generateSentence(selectedWords);
//       print('✅ Sentence set in state: $sentence');
//       setState(() {
//         generatedSentence = sentence;
//         translatedHindi = '';
//         translatedKannada = '';
//       });
//     } catch (e) {
//       print('❌ Error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to generate sentence")),
//       );
//     }
//   }

//   Future<void> speakSentence(String sentence) async {
//     await flutterTts.setLanguage("en-US");
//     await flutterTts.setSpeechRate(0.5);
//     await flutterTts.speak(sentence);
//   }

//   Future<void> showTranslation(String langCode, String title) async {
//     try {
//       final translated = await translateText(generatedSentence, langCode);
//       setState(() {
//         if (langCode == 'hi') {
//           translatedHindi = translated;
//         } else if (langCode == 'kn') {
//           translatedKannada = translated;
//         }
//       });
//     } catch (e) {
//       print("❌ Translation failed: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("🧠 Icon Sentence Generator")),
//       body: categories.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: DropdownButton<String>(
//                     value: selectedCategory,
//                     isExpanded: true,
//                     hint: Text("Select Category"),
//                     items: categories.map((category) {
//                       return DropdownMenuItem<String>(
//                         value: category.category,
//                         child: Text(category.category),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedCategory = value;
//                       });
//                     },
//                   ),
//                 ),
//                 if (selectedCategory != null)
//                   Expanded(
//                     child: GridView.builder(
//                       padding: EdgeInsets.symmetric(horizontal: 12),
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 4,
//                         mainAxisSpacing: 8,
//                         crossAxisSpacing: 8,
//                       ),
//                       itemCount: categories
//                           .firstWhere(
//                               (cat) => cat.category == selectedCategory)
//                           .items
//                           .length,
//                       itemBuilder: (context, index) {
//                         final selectedCat = categories.firstWhere(
//                             (cat) => cat.category == selectedCategory);
//                         final icon = selectedCat.items[index];
//                         final isSelected = selectedWords.contains(icon.word);
//                         return GestureDetector(
//                           onTap: () => toggleSelection(icon.word),
//                           child: Container(
//                             padding: EdgeInsets.all(6),
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: isSelected
//                                     ? Colors.green
//                                     : Colors.grey.shade400,
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Column(
//                               children: [
//                                 Expanded(child: Image.asset(icon.image)),
//                                 Text(icon.word,
//                                     style: TextStyle(fontSize: 12),
//                                     textAlign: TextAlign.center),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 if (selectedCategory == null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 24.0),
//                     child: Text(
//                       "⬆️ Select a category to view icons",
//                       style: TextStyle(fontSize: 16, color: Colors.grey),
//                     ),
//                   ),
//               ],
//             ),
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               if (generatedSentence.isNotEmpty)
//                 Column(
//                   children: [
//                     Text(
//                       "💬 $generatedSentence",
//                       style: TextStyle(
//                           fontSize: 16, fontWeight: FontWeight.w500),
//                       textAlign: TextAlign.center,
//                     ),
//                     if (translatedHindi.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 6.0),
//                         child: Text(
//                           "🇮🇳 Hindi: $translatedHindi",
//                           style: TextStyle(
//                               fontSize: 15, color: Colors.deepOrange),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     if (translatedKannada.isNotEmpty)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 4.0),
//                         child: Text(
//                           "🇮🇳 Kannada: $translatedKannada",
//                           style:
//                               TextStyle(fontSize: 15, color: Colors.indigo),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     SizedBox(height: 10),
//                   ],
//                 )
//               else
//                 Column(
//                   children: [
//                     Text(
//                       "💬 No sentence generated yet.",
//                       style: TextStyle(fontSize: 15, color: Colors.grey),
//                       textAlign: TextAlign.center,
//                     ),
//                     SizedBox(height: 10),
//                   ],
//                 ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: generateSentenceFromSelected,
//                     icon: Icon(Icons.auto_fix_high),
//                     label: Text("Generate"),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: generatedSentence.isNotEmpty
//                         ? () => speakSentence(generatedSentence)
//                         : null,
//                     icon: Icon(Icons.volume_up),
//                     label: Text("Speak"),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: generatedSentence.isNotEmpty
//                         ? () => showTranslation("hi", "Hindi Translation")
//                         : null,
//                     child: Text("Translate to Hindi"),
//                   ),
//                   ElevatedButton(
//                     onPressed: generatedSentence.isNotEmpty
//                         ? () => showTranslation("kn", "Kannada Translation")
//                         : null,
//                     child: Text("Translate to Kannada"),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

//////////////////////////////////

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/icon_category.dart';
import '../services/sentence_service.dart';
import '../utils/icon_suggestion.dart';
import './categories_icons_screen.dart';

import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<IconSuggestion> suggestions = [];
  TextEditingController userSentenceController = TextEditingController();
  List<String> iconPriorityList = []; // dynamically updated by sentence
  List<IconItem> matchedIcons =
      []; // ← will hold only the icons from the backend
  List<IconCategory> categories = [];
  List<String> selectedWords = [];
  String generatedSentence = '';
  String translatedHindi = '';
  String translatedKannada = '';
  String? selectedCategory;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    loadIconData();
    loadSuggestionsJsonl();
  }

  Future<void> loadIconData() async {
    final String jsonString = await rootBundle.loadString(
      'icon_categories.json',
    );
    final List<dynamic> jsonList = jsonDecode(jsonString);

    setState(() {
      categories = jsonList
          .map((category) => IconCategory.fromJson(category))
          .toList();
    });
  }

  Future<void> loadSuggestionsJsonl() async {
    final data = await rootBundle.loadString('icon_categories.json');
    final lines = data.split('\n').where((line) => line.trim().isNotEmpty);

    setState(() {
      suggestions = lines.map((line) {
        final jsonLine = json.decode(line);
        return IconSuggestion.fromJson(jsonLine);
      }).toList();
    });
  }

  void toggleSelection(String word) {
    setState(() {
      if (selectedWords.contains(word)) {
        selectedWords.remove(word);
      } else {
        selectedWords.add(word);
      }
    });
  }

  Future<void> rearrangeIconsBySentence(String sentence) async {
    try {
      final response = await http.post(
        Uri.parse(
          "http://127.0.0.1:5000/rearrange_icons",
        ), // use local IP if on phone
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"sentence": sentence}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> icons = data["icons"];

        setState(() {
          matchedIcons = icons.map((iconJson) {
            return IconItem.fromJson(iconJson);
          }).toList();
        });
      } else {
        print("Backend error: ${response.body}");
      }
    } catch (e) {
      print("Failed to rearrange icons: $e");
    }
  }

  Future<void> generateSentenceFromSelected() async {
    if (selectedWords.isEmpty) return;

    try {
      final sentence = await generateSentence(selectedWords);
      print('✅ Sentence set in state: $sentence');
      setState(() {
        generatedSentence = sentence;
        translatedHindi = '';
        translatedKannada = '';
      });
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to generate sentence")));
    }
  }

  Future<void> speakSentence(String sentence) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(sentence);
  }

  Future<void> showTranslation(String langCode, String title) async {
    try {
      final translated = await translateText(generatedSentence, langCode);
      setState(() {
        if (langCode == 'hi') {
          translatedHindi = translated;
        } else if (langCode == 'kn') {
          translatedKannada = translated;
        }
      });
    } catch (e) {
      print("❌ Translation failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🧠 Icon Sentence Generator")),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CategoryIconsScreen(category: category),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFCF7FF),
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              category.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            category.category,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (generatedSentence.isNotEmpty)
                Column(
                  children: [
                    Text(
                      "💬 $generatedSentence",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (translatedHindi.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          "🇮🇳 Hindi: $translatedHindi",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.deepOrange,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (translatedKannada.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "🇮🇳 Kannada: $translatedKannada",
                          style: TextStyle(fontSize: 15, color: Colors.indigo),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(height: 10),
                  ],
                )
              else
                Column(
                  children: [
                    Text(
                      "💬 No sentence generated yet.",
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: generateSentenceFromSelected,
                    icon: Icon(Icons.auto_fix_high),
                    label: Text("Generate"),
                  ),
                  ElevatedButton.icon(
                    onPressed: generatedSentence.isNotEmpty
                        ? () => speakSentence(generatedSentence)
                        : null,
                    icon: Icon(Icons.volume_up),
                    label: Text("Speak"),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: generatedSentence.isNotEmpty
                        ? () => showTranslation("hi", "Hindi Translation")
                        : null,
                    child: Text("Translate to Hindi"),
                  ),
                  ElevatedButton(
                    onPressed: generatedSentence.isNotEmpty
                        ? () => showTranslation("kn", "Kannada Translation")
                        : null,
                    child: Text("Translate to Kannada"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
