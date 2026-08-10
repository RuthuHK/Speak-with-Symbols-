// // lib/screens/home_controller.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import '../models/icon_category.dart';
// import '../utils/icon_suggestion.dart';
// import '../utils/sentence_modifier.dart';
// import '../services/sentence_service.dart';
// import 'falling_icon.dart';

// class HomeController {
//   late TickerProvider tickerProvider;
//   List<IconSuggestion> suggestions = [];
//   TextEditingController userSentenceController = TextEditingController();
//   List<String> iconPriorityList = [];
//   List<IconCategory> categories = [];
//   List<String> selectedWords = [];
//   String generatedSentence = '';
//   String translatedHindi = '';
//   String translatedKannada = '';
//   String? selectedCategory;
//   String selectedSpeechLang = 'en';
//   final FlutterTts flutterTts = FlutterTts();
//   List<FallingIcon> fallingIcons = [];
//   int iconFallCount = 0;

//   void init(TickerProvider provider) {
//     tickerProvider = provider;
//     loadIconData();
//     loadSuggestionsJsonl();
//   }

//   Future<void> loadSuggestionsJsonl() async {
//     final data = await rootBundle.loadString('assets/suggestions.jsonl');
//     final lines = data.split('\n').where((line) => line.trim().isNotEmpty);
//     suggestions = lines.map((line) {
//       final jsonLine = json.decode(line);
//       return IconSuggestion.fromJson(jsonLine);
//     }).toList();
//   }

//   Future<void> loadIconData() async {
//     final String jsonString = await rootBundle.loadString('assets/icon_categories.json');
//     final List<dynamic> jsonList = jsonDecode(jsonString);
//     categories = jsonList.map((category) => IconCategory.fromJson(category)).toList();
//   }

//   void toggleSelection(String word, void Function(void Function()) setState) {
//     setState(() {
//       if (selectedWords.contains(word)) {
//         selectedWords.remove(word);
//       } else {
//         selectedWords.add(word);
//         _startFallingIcon(word, setState);
//       }
//     });
//   }

//   void _startFallingIcon(String word, void Function(void Function()) setState) {
//     final icon = categories.expand((c) => c.items).firstWhere(
//       (item) => item.word == word,
//       orElse: () => IconItem(word: word, image: 'assets/default.png'),
//     );
//     final newFalling = FallingIcon(
//       key: UniqueKey(),
//       imagePath: icon.image,
//       startX: 40.0 + (iconFallCount % 6) * 60.0,
//     );
//     fallingIcons.add(newFalling);
//     iconFallCount++;

//     Future.delayed(Duration(milliseconds: 1200), () {
//       setState(() {
//         fallingIcons.removeWhere((f) => f.key == newFalling.key);
//       });
//     });
//   }

//   void rearrangeIconsBySentence(String sentence, void Function(void Function()) setState) {
//     final match = suggestions.firstWhere(
//       (s) => sentence.toLowerCase().contains(s.bot.toLowerCase()),
//       orElse: () => IconSuggestion(bot: '', suggested: []),
//     );
//     setState(() {
//       iconPriorityList = match.suggested.map((w) => w.toLowerCase()).toList();
//     });
//   }

//   Future<void> generateSentenceFromSelected(void Function(void Function()) setState, BuildContext context) async {
//     if (selectedWords.isEmpty) return;
//     try {
//       final sentence = await generateSentence(selectedWords);
//       setState(() {
//         generatedSentence = sentence;
//         translatedHindi = '';
//         translatedKannada = '';
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to generate sentence")),
//       );
//     }
//   }

//   Future<void> speakSentence(String sentence) async {
//     String langCode;
//     String sentenceToSpeak = sentence;
//     if (selectedSpeechLang == 'hi') {
//       langCode = 'hi-IN';
//       sentenceToSpeak = translatedHindi.isNotEmpty ? translatedHindi : sentence;
//     } else if (selectedSpeechLang == 'kn') {
//       langCode = 'kn-IN';
//       sentenceToSpeak = translatedKannada.isNotEmpty ? translatedKannada : sentence;
//     } else {
//       langCode = 'en-US';
//     }

//     await flutterTts.setLanguage(langCode);
//     await flutterTts.setSpeechRate(0.5);
//     await flutterTts.speak(sentenceToSpeak);
//   }

//   Future<void> showTranslation(String langCode, void Function(void Function()) setState) async {
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

//   void _negateSentence(void Function(void Function()) setState, BuildContext context) {
//   if (SentenceModifier.isNegative(generatedSentence)) return;

//   final modified = SentenceModifier.toNegative(generatedSentence);
//   if (modified == generatedSentence) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Can't negate this sentence easily.")),
//     );
//     return;
//   }

//   setState(() {
//     generatedSentence = modified;
//     translatedHindi = '';
//     translatedKannada = '';
//   });

//   speakSentence(generatedSentence);
// }

// void _makePositiveSentence(void Function(void Function()) setState, BuildContext context) {
//   final modified = SentenceModifier.toPositive(generatedSentence);
//   if (modified == generatedSentence) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("This sentence is already positive.")),
//     );
//     return;
//   }

//   setState(() {
//     generatedSentence = modified;
//     translatedHindi = '';
//     translatedKannada = '';
//   });

//   speakSentence(generatedSentence);
// }

//   Widget buildMainColumn(BuildContext context, void Function(void Function()) setState) {
//     return categories.isEmpty
//         ? Center(child: CircularProgressIndicator())
//         : Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                 child: DropdownButton<String>(
//                   value: selectedCategory,
//                   isExpanded: true,
//                   hint: Text("Select Category"),
//                   items: categories.map((category) {
//                     return DropdownMenuItem<String>(
//                       value: category.category,
//                       child: Text(category.category),
//                     );
//                   }).toList(),
//                   onChanged: (value) => setState(() => selectedCategory = value),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: userSentenceController,
//                         decoration: InputDecoration(
//                           hintText: "Type a sentence to suggest icons...",
//                           border: OutlineInputBorder(),
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 10),
//                     ElevatedButton(
//                       onPressed: () {
//                         final input = userSentenceController.text.trim();
//                         if (input.isNotEmpty) {
//                           rearrangeIconsBySentence(input, setState);
//                           FocusScope.of(context).unfocus();
//                         }
//                       },
//                       child: Text("Okay"),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 10),
//               if (selectedCategory != null)
//                 Expanded(
//                   child: GridView.builder(
//                     padding: EdgeInsets.symmetric(horizontal: 12),
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       mainAxisSpacing: 8,
//                       crossAxisSpacing: 8,
//                     ),
//                     itemCount: categories
//                         .firstWhere((cat) => cat.category == selectedCategory)
//                         .items
//                         .length,
//                     itemBuilder: (context, index) {
//                       final selectedCat = categories.firstWhere((cat) => cat.category == selectedCategory);
//                       List iconList = List.from(selectedCat.items);

//                       iconList.sort((a, b) {
//                         final aIndex = iconPriorityList.indexOf(a.word.toLowerCase());
//                         final bIndex = iconPriorityList.indexOf(b.word.toLowerCase());
//                         if (aIndex == -1 && bIndex == -1) return 0;
//                         if (aIndex == -1) return 1;
//                         if (bIndex == -1) return -1;
//                         return aIndex.compareTo(bIndex);
//                       });

//                       final icon = iconList[index];
//                       final isSelected = selectedWords.contains(icon.word);

//                       return GestureDetector(
//                         onTap: () => toggleSelection(icon.word, setState),
//                         child: AnimatedContainer(
//                           duration: Duration(milliseconds: 300),
//                           padding: EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             border: Border.all(
//                               color: isSelected ? Colors.green : Colors.grey.shade400,
//                               width: 2,
//                             ),
//                             boxShadow: isSelected
//                                 ? [
//                                     BoxShadow(
//                                       color: Colors.greenAccent.withOpacity(0.3),
//                                       blurRadius: 6,
//                                       offset: Offset(0, 4),
//                                     )
//                                   ]
//                                 : [],
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Column(
//                             children: [
//                               Expanded(child: Image.asset(icon.image)),
//                               Text(icon.word, style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 )
//               else
//                 Padding(
//                   padding: const EdgeInsets.only(top: 24.0),
//                   child: Text(
//                     "⬆️ Select a category to view icons",
//                     style: TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                 ),
//             ],
//           );
//   }

//   Widget buildBottomBar(BuildContext context, void Function(void Function()) setState) {
//     return SafeArea(
//       child: AnimatedSwitcher(
//         duration: Duration(milliseconds: 500),
//         child: Container(
//           key: ValueKey(selectedWords.length),
//           padding: const EdgeInsets.all(12.0),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             boxShadow: [
//               BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2)),
//             ],
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (selectedWords.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12.0),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Expanded(
//                           child: SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: Row(
//                               children: selectedWords.map((word) {
//                                 final icon = categories.expand((cat) => cat.items).firstWhere(
//                                       (item) => item.word == word,
//                                       orElse: () => IconItem(word: word, image: 'assets/default.png'),
//                                     );
//                                 return Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                                   child: Column(
//                                     children: [
//                                       Image.asset(icon.image, width: 36, height: 36),
//                                       Text(word, style: TextStyle(fontSize: 10)),
//                                     ],
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () => setState(() {
//                             selectedWords.clear();
//                             generatedSentence = '';
//                             translatedHindi = '';
//                             translatedKannada = '';
//                           }),
//                           icon: Icon(Icons.clear, color: Colors.red),
//                         )
//                       ],
//                     ),
//                   ),
//                 if (generatedSentence.isNotEmpty)
//                   Column(
//                     children: [
//                       Text("💬 $generatedSentence",
//                           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                           textAlign: TextAlign.center),
//                       if (translatedHindi.isNotEmpty)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 6.0),
//                           child: Text("🇮🇳 Hindi: $translatedHindi",
//                               style: TextStyle(fontSize: 15, color: Colors.deepOrange),
//                               textAlign: TextAlign.center),
//                         ),
//                       if (translatedKannada.isNotEmpty)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 4.0),
//                           child: Text("🇮🇳 Kannada: $translatedKannada",
//                               style: TextStyle(fontSize: 15, color: Colors.indigo),
//                               textAlign: TextAlign.center),
//                         ),
//                       SizedBox(height: 10),
//                     ],
//                   ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton.icon(
//                       onPressed: () => generateSentenceFromSelected(setState, context),
//                       icon: Icon(Icons.auto_fix_high),
//                       label: Text("Generate"),
//                     ),
//                     ElevatedButton.icon(
//                       onPressed: generatedSentence.isNotEmpty
//                           ? () => speakSentence(generatedSentence)
//                           : null,
//                       icon: Icon(Icons.volume_up),
//                       label: Text("Speak"),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 10),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                       onPressed: generatedSentence.isNotEmpty
//                           ? () => showTranslation("hi", setState)
//                           : null,
//                       child: Text("Translate to Hindi"),
//                     ),
//                     ElevatedButton(
//                       onPressed: generatedSentence.isNotEmpty
//                           ? () => showTranslation("kn", setState)
//                           : null,
//                       child: Text("Translate to Kannada"),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 10),
//                 if (generatedSentence.isNotEmpty)
//                   DropdownButton<String>(
//                     value: selectedSpeechLang,
//                     isExpanded: true,
//                     items: [
//                       DropdownMenuItem(value: 'en', child: Text("🔊 Speak (English)")),
//                       DropdownMenuItem(value: 'hi', child: Text("🔊 Speak (Hindi)")),
//                       DropdownMenuItem(value: 'kn', child: Text("🔊 Speak (Kannada)")),
//                     ],
//                     onChanged: (value) async {
//                       if (value != null) {
//                         setState(() => selectedSpeechLang = value);
//                         if (value == 'hi' && translatedHindi.isEmpty) {
//                           await showTranslation('hi', setState);
//                         } else if (value == 'kn' && translatedKannada.isEmpty) {
//                           await showTranslation('kn', setState);
//                         }
//                         speakSentence(generatedSentence);
//                       }
//                     },
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/screens/home_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/icon_category.dart';
import '../utils/icon_suggestion.dart';
import '../services/sentence_service.dart';
import 'falling_icon.dart';
import '../utils/sentence_modifier.dart'; // ✅ NEW

class HomeController {
  late TickerProvider tickerProvider;
  List<IconSuggestion> suggestions = [];
  TextEditingController userSentenceController = TextEditingController();
  List<IconItem> matchedIcons =
      []; // ← will hold only the icons from the backend
  List<String> iconPriorityList = [];
  List<IconCategory> categories = [];
  List<String> selectedWords = [];
  String generatedSentence = '';
  String translatedHindi = '';
  String translatedKannada = '';
  String? selectedCategory;
  String selectedSpeechLang = 'en';
  final FlutterTts flutterTts = FlutterTts();
  List<FallingIcon> fallingIcons = [];
  int iconFallCount = 0;

  // User-pinned favourite icon words (persist if needed)
  List<String> pinnedIcons = [];

  // Recently used icon words (persist if needed)
  List<String> recentlyUsedIcons = [];
  final int maxRecentlyUsed = 10; // Limit for recents
  List<String> get favouritesCategoryIcons {
    final combined = List<String>.from(pinnedIcons);
    for (var icon in recentlyUsedIcons) {
      if (!combined.contains(icon)) combined.add(icon);
    }
    return combined;
  }

  Future<void> loadSuggestionsJsonl() async {
    final data = await rootBundle.loadString('assets/suggestions.jsonl');
    final lines = data.split('\n').where((line) => line.trim().isNotEmpty);
    suggestions = lines.map((line) {
      final jsonLine = json.decode(line);
      return IconSuggestion.fromJson(jsonLine);
    }).toList();
  }

  Future<void> loadIconData() async {
    final String jsonString = await rootBundle.loadString(
      'assets/icon_categories.json',
    );
    final List<dynamic> jsonList = jsonDecode(jsonString);
    categories = jsonList
        .map((category) => IconCategory.fromJson(category))
        .toList();
  }

  void toggleSelection(
    String word,
    void Function(void Function()) setState,
    BuildContext context,
  ) {
    final wasAdded = !selectedWords.contains(word);

    setState(() {
      if (!wasAdded) {
        selectedWords.remove(word);
      } else {
        selectedWords.add(word);
        _startFallingIcon(word, setState);
        updateRecentlyUsed(word);
      }
    });

    // Only generate sentence when a new word is added
    if (wasAdded) {
      generateSentenceFromSelected(setState, context);
    }
  }

  void updateRecentlyUsed(String iconWord) {
    // Don't add if already pinned (will be shown anyway)
    if (!pinnedIcons.contains(iconWord)) {
      recentlyUsedIcons.remove(iconWord);
      recentlyUsedIcons.insert(0, iconWord); // Most recent at front
      if (recentlyUsedIcons.length > maxRecentlyUsed) {
        recentlyUsedIcons.removeLast();
      }
    }
    // Optionally: persist recentlyUsedIcons here
  }

  void togglePin(String iconWord, void Function(void Function()) setState) {
    setState(() {
      if (pinnedIcons.contains(iconWord)) {
        pinnedIcons.remove(iconWord);
      } else {
        pinnedIcons.add(iconWord);
      }
      // Optionally: persist pinnedIcons here
    });
  }

  void _startFallingIcon(String word, void Function(void Function()) setState) {
    final icon = categories
        .expand((c) => c.items)
        .firstWhere(
          (item) => item.word == word,
          orElse: () => IconItem(word: word, image: 'assets/default.png'),
        );
    final newFalling = FallingIcon(
      key: UniqueKey(),
      imagePath: icon.image,
      startX: 40.0 + (iconFallCount % 6) * 60.0,
    );
    fallingIcons.add(newFalling);
    iconFallCount++;

    Future.delayed(Duration(milliseconds: 1200), () {
      setState(() {
        fallingIcons.removeWhere((f) => f.key == newFalling.key);
      });
    });
  }

  void rearrangeIconsBySentence(
    String sentence,
    void Function(void Function()) setState,
  ) {
    final match = suggestions.firstWhere(
      (s) => sentence.toLowerCase().contains(s.bot.toLowerCase()),
      orElse: () => IconSuggestion(bot: '', suggested: []),
    );
    setState(() {
      iconPriorityList = match.suggested.map((w) => w.toLowerCase()).toList();
    });
  }

  Future<void> generateSentenceFromSelected(
    void Function(void Function()) setState,
    BuildContext context,
  ) async {
    if (selectedWords.isEmpty) return;
    try {
      final sentence = await generateSentence(selectedWords);

      setState(() {
        generatedSentence = sentence;
        translatedHindi = '';
        translatedKannada = '';
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to generate sentence"),
            duration: Duration(milliseconds: 1000),
          ),
        );
      } else {
        debugPrint("⚠️ Cannot show snackbar: context is unmounted.");
      }
    }
  }

  Future<void> speakSentence(String sentence) async {
    String langCode;
    String sentenceToSpeak = sentence;
    if (selectedSpeechLang == 'hi') {
      langCode = 'hi-IN';
      sentenceToSpeak = translatedHindi.isNotEmpty ? translatedHindi : sentence;
    } else if (selectedSpeechLang == 'kn') {
      langCode = 'kn-IN';
      sentenceToSpeak = translatedKannada.isNotEmpty
          ? translatedKannada
          : sentence;
    } else {
      langCode = 'en-US';
    }

    await flutterTts.setLanguage(langCode);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.speak(sentenceToSpeak);
  }

  Future<void> showTranslation(
    String langCode,
    void Function(void Function()) setState,
  ) async {
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

  void _negateSentence(
    void Function(void Function()) setState,
    BuildContext context,
  ) {
    if (SentenceModifier.isNegative(generatedSentence)) return;

    final modified = SentenceModifier.toNegative(generatedSentence);
    if (modified == generatedSentence) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Can't negate this sentence easily.")),
      );
      return;
    }

    setState(() {
      generatedSentence = modified;
      translatedHindi = '';
      translatedKannada = '';
    });

    speakSentence(generatedSentence);
  }

  void _makePositiveSentence(
    void Function(void Function()) setState,
    BuildContext context,
  ) {
    final modified = SentenceModifier.toPositive(generatedSentence);
    if (modified == generatedSentence) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("This sentence is already positive.")),
      );
      return;
    }

    setState(() {
      generatedSentence = modified;
      translatedHindi = '';
      translatedKannada = '';
    });

    speakSentence(generatedSentence);
  }

  Widget buildMainColumn(
    BuildContext context,
    void Function(void Function()) setState,
  ) {
    return categories.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: userSentenceController,
                        decoration: InputDecoration(
                          hintText: "Type a sentence to suggest icons...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        final input = userSentenceController.text.trim();
                        if (input.isNotEmpty) {
                          rearrangeIconsBySentence(input, setState);
                          FocusScope.of(context).unfocus();
                        }
                      },
                      child: Text("Okay"),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 110,
                child: Row(
                  children: [
                    // --- Fixed Favourites Category ---
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = 'Favourites';
                        });
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(
                          left: 16,
                          right: 8,
                        ), // match your padding
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: selectedCategory == 'Favourites'
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: selectedCategory == 'Favourites'
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context).primaryColor
                                        .withAlpha((0.15 * 255).toInt()),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 36),
                            SizedBox(height: 8),
                            Text(
                              'Favourites',
                              style: TextStyle(
                                fontWeight: selectedCategory == 'Favourites'
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: selectedCategory == 'Favourites'
                                    ? Theme.of(context).primaryColor
                                    : Colors.black,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // --- Scrollable Ordinary Categories ---
                    Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(
                          right: 16,
                        ), // right padding only
                        itemCount: categories.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected =
                              selectedCategory == category.category;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategory = category.category;
                              });
                            },
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Theme.of(context).primaryColor
                                              .withAlpha((0.15 * 255).toInt()),
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Image.asset(
                                      category.image,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    category.category,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Colors.black,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              if (selectedCategory != null)
                Expanded(
                  child: selectedCategory == 'Favourites'
                      // --- FAVOURITES GRID ---
                      ? GridView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                          itemCount: favouritesCategoryIcons.length,
                          itemBuilder: (context, index) {
                            final iconWord = favouritesCategoryIcons[index];
                            final icon = categories
                                .expand((cat) => cat.items)
                                .firstWhere(
                                  (item) => item.word == iconWord,
                                  orElse: () => IconItem(
                                    word: iconWord,
                                    image: 'assets/default.png',
                                  ),
                                );
                            if (icon.image == 'assets/default.png') {
                              // Show a special widget, or skip rendering
                              return SizedBox.shrink(); // or a custom "not found" widget
                            }
                            final isSelected = selectedWords.contains(
                              icon.word,
                            );

                            return GestureDetector(
                              onTap: () =>
                                  toggleSelection(icon.word, setState, context),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.green
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.greenAccent
                                                .withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      children: [
                                        Expanded(
                                          child: Image.asset(icon.image),
                                        ),
                                        Text(
                                          icon.word,
                                          style: TextStyle(fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    // Pin/unpin button in top right
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: Icon(
                                          pinnedIcons.contains(icon.word)
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                        onPressed: () =>
                                            togglePin(icon.word, setState),
                                        tooltip: pinnedIcons.contains(icon.word)
                                            ? 'Unpin from Favourites'
                                            : 'Pin to Favourites',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      // --- NORMAL CATEGORY GRID ---
                      : GridView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                          itemCount: categories
                              .firstWhere(
                                (cat) => cat.category == selectedCategory,
                              )
                              .items
                              .length,
                          itemBuilder: (context, index) {
                            final selectedCat = categories.firstWhere(
                              (cat) => cat.category == selectedCategory,
                            );
                            List iconList = List.from(selectedCat.items);

                            iconList.sort((a, b) {
                              final aIndex = iconPriorityList.indexOf(
                                a.word.toLowerCase(),
                              );
                              final bIndex = iconPriorityList.indexOf(
                                b.word.toLowerCase(),
                              );
                              if (aIndex == -1 && bIndex == -1) return 0;
                              if (aIndex == -1) return 1;
                              if (bIndex == -1) return -1;
                              return aIndex.compareTo(bIndex);
                            });

                            final icon = iconList[index];
                            final isSelected = selectedWords.contains(
                              icon.word,
                            );

                            return GestureDetector(
                              onTap: () =>
                                  toggleSelection(icon.word, setState, context),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.green
                                        : Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: Colors.greenAccent
                                                .withOpacity(0.3),
                                            blurRadius: 6,
                                            offset: Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      children: [
                                        Expanded(
                                          child: Image.asset(icon.image),
                                        ),
                                        Text(
                                          icon.word,
                                          style: TextStyle(fontSize: 12),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                    // Pin/unpin button in top right
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: Icon(
                                          pinnedIcons.contains(icon.word)
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                        onPressed: () =>
                                            togglePin(icon.word, setState),
                                        tooltip: pinnedIcons.contains(icon.word)
                                            ? 'Unpin from Favourites'
                                            : 'Pin to Favourites',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Text(
                    "⬆️ Select a category to view icons",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
            ],
          );
  }

  Future<void> init(TickerProvider provider) async {
    tickerProvider = provider;
    await loadIconData();
    await loadSuggestionsJsonl();
  }

  Widget buildBottomBar(
    BuildContext context,
    void Function(void Function()) setState,
  ) {
    return SafeArea(
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: Container(
          key: ValueKey(selectedWords.length),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedWords.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: selectedWords.map((word) {
                                final icon = categories
                                    .expand((cat) => cat.items)
                                    .firstWhere(
                                      (item) => item.word == word,
                                      orElse: () => IconItem(
                                        word: word,
                                        image: 'assets/default.png',
                                      ),
                                    );
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0,
                                  ),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        icon.image,
                                        width: 36,
                                        height: 36,
                                      ),
                                      Text(
                                        word,
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (selectedWords.isNotEmpty) {
                                selectedWords.removeLast();
                                generateSentenceFromSelected(setState, context);
                              } else {
                                generatedSentence = '';
                                translatedHindi = '';
                                translatedKannada = '';
                              }
                            });
                          },
                          icon: Icon(Icons.backspace, color: Colors.red),
                          tooltip: 'Remove last icon',
                        ),
                      ],
                    ),
                  ),
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

                      // 😄😊😞 Emoji buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () =>
                                  _makePositiveSentence(setState, context),
                              icon: Text('😊', style: TextStyle(fontSize: 24)),
                              tooltip: 'Make Positive',
                            ),
                            SizedBox(width: 16),
                            IconButton(
                              onPressed: () =>
                                  _negateSentence(setState, context),
                              icon: Text('😞', style: TextStyle(fontSize: 24)),
                              tooltip: 'Make Negative',
                            ),
                          ],
                        ),
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
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.indigo,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(height: 10),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ElevatedButton.icon(
                    //   onPressed: () => generateSentenceFromSelected(setState, context),
                    //   icon: Icon(Icons.auto_fix_high),
                    //   label: Text("Generate"),
                    // ),
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
                          ? () => showTranslation("hi", setState)
                          : null,
                      child: Text("Translate to Hindi"),
                    ),
                    ElevatedButton(
                      onPressed: generatedSentence.isNotEmpty
                          ? () => showTranslation("kn", setState)
                          : null,
                      child: Text("Translate to Kannada"),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                if (generatedSentence.isNotEmpty)
                  DropdownButton<String>(
                    value: selectedSpeechLang,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text("🔊 Speak (English)"),
                      ),
                      DropdownMenuItem(
                        value: 'hi',
                        child: Text("🔊 Speak (Hindi)"),
                      ),
                      DropdownMenuItem(
                        value: 'kn',
                        child: Text("🔊 Speak (Kannada)"),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value != null) {
                        setState(() => selectedSpeechLang = value);
                        if (value == 'hi' && translatedHindi.isEmpty) {
                          await showTranslation('hi', setState);
                        } else if (value == 'kn' && translatedKannada.isEmpty) {
                          await showTranslation('kn', setState);
                        }
                        speakSentence(generatedSentence);
                      }
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
