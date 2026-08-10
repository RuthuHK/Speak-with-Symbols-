// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:http/http.dart' as http;

// import '../models/icon_item.dart';
// import '../models/icon_category.dart';
// import '../utils/icon_suggestion.dart';
// import '../utils/sentence_modifier.dart';
// import '../services/sentence_service.dart';
// import 'falling_icon.dart';

// class HomeController {
//   late TickerProvider tickerProvider;

//   // Core data
//   List<IconCategory> categories = [];
//   List<IconItem> matchedIcons = [];
//   List<IconSuggestion> suggestions = [];
//   List<FallingIcon> fallingIcons = [];
//   List<String> iconPriorityList = [];
//   List<String> selectedWords = [];

//   // Favourites / recently used state
//   List<String> pinnedIcons = [];
//   List<String> recentlyUsedIcons = [];
//   final int maxRecentlyUsed = 10;
//   List<String> get favouritesCategoryIcons {
//     final combined = List<String>.from(pinnedIcons);
//     for (var icon in recentlyUsedIcons) {
//       if (!combined.contains(icon)) combined.add(icon);
//     }
//     return combined;
//   }

//   // Suggestions
//   List<String> suggestedIconWords = [];

//   // UI/display state
//   String generatedSentence = '';
//   String translatedHindi = '';
//   String translatedKannada = '';
//   String? selectedCategory;
//   String selectedSpeechLang = 'en';
//   int iconFallCount = 0;

//   TextEditingController userSentenceController = TextEditingController();
//   final FlutterTts flutterTts = FlutterTts();

//   // ---------- Initialization ----------

//   Future<void> loadSuggestionsJsonl() async {
//     final data = await rootBundle.loadString('assets/suggestions.jsonl');
//     final lines = data.split('\n').where((line) => line.trim().isNotEmpty);
//     suggestions = lines.map((line) {
//       final jsonLine = json.decode(line);
//       return IconSuggestion.fromJson(jsonLine);
//     }).toList();
//   }

//   Future<void> loadIconData() async {
//     final data = await rootBundle.loadString('assets/icon_categories.json');
//     final jsonList = jsonDecode(data);
//     categories = jsonList
//         .map<IconCategory>((category) => IconCategory.fromJson(category))
//         .toList();
//   }

//   Future<void> init(TickerProvider provider) async {
//     tickerProvider = provider;
//     await loadIconData();
//     await loadSuggestionsJsonl();
//   }

//   // ---------- Selection / Favourites logic ----------

//   void toggleSelection(
//     String word,
//     void Function(void Function()) setState,
//     BuildContext context,
//   ) {
//     final wasAdded = !selectedWords.contains(word);
//     setState(() {
//       if (!wasAdded) {
//         selectedWords.remove(word);
//       } else {
//         selectedWords.add(word);
//         _startFallingIcon(word, setState);
//         updateRecentlyUsed(word);
//       }
//     });
//     if (wasAdded) {
//       generateSentenceFromSelected(setState, context);
//     }
//   }

//   void togglePin(String iconWord, void Function(void Function()) setState) {
//     setState(() {
//       if (pinnedIcons.contains(iconWord)) {
//         pinnedIcons.remove(iconWord);
//       } else {
//         pinnedIcons.add(iconWord);
//       }
//     });
//   }

//   void updateRecentlyUsed(String iconWord) {
//     if (!pinnedIcons.contains(iconWord)) {
//       recentlyUsedIcons.remove(iconWord);
//       recentlyUsedIcons.insert(0, iconWord);
//       if (recentlyUsedIcons.length > maxRecentlyUsed) {
//         recentlyUsedIcons.removeLast();
//       }
//     }
//   }

//   void _startFallingIcon(String word, void Function(void Function()) setState) {
//     final icon = categories
//         .expand((cat) => cat.items)
//         .firstWhere(
//           (item) => item.word == word,
//           orElse: () => IconItem(
//             word: word,
//             image: 'assets/icons/core_vocab_places/default.png',
//             name: 'Default Name',
//             desc: 'No description found',
//             embedding: [],
//           ),
//         );
//     final falling = FallingIcon(
//       key: UniqueKey(),
//       imagePath: icon.image,
//       startX: 40.0 + (iconFallCount % 6) * 60.0,
//     );
//     fallingIcons.add(falling);
//     iconFallCount++;
//     Future.delayed(Duration(milliseconds: 1200), () {
//       setState(() {
//         fallingIcons.removeWhere((f) => f.key == falling.key);
//       });
//     });
//   }

//   // ---------- Backend/UI/AI Features ----------

//   void rearrangeIconsBySentence(
//     String sentence,
//     void Function(void Function()) setState,
//   ) {
//     final match = suggestions.firstWhere(
//       (s) => sentence.toLowerCase().contains(s.bot.toLowerCase()),
//       orElse: () => IconSuggestion(bot: '', suggested: []),
//     );
//     setState(() {
//       iconPriorityList = match.suggested.map((w) => w.toLowerCase()).toList();
//     });
//   }

//   Future<void> rearrangeIconsFromBackend(
//     String sentence,
//     void Function(void Function()) setState,
//   ) async {
//     try {
//       final response = await http.post(
//         Uri.parse("http://10.30.200.179:5000/rearrange_icons"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"sentence": sentence}),
//       );
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List<dynamic> icons = data["icons"];
//         matchedIcons = icons.map((json) => IconItem.fromJson(json)).toList();
//         setState(() {});
//       } else {
//         print("❌ Backend responded with: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("❌ Error in rearrangeIconsFromBackend: $e");
//     }
//   }

//   // ---------- TTS / Generation / Translation ----------

//   Future<void> generateSentenceFromSelected(
//     void Function(void Function()) setState,
//     BuildContext context,
//   ) async {
//     if (selectedWords.isEmpty) return;
//     try {
//       final sentence = await generateSentence(selectedWords);
//       setState(() {
//         generatedSentence = sentence;
//         translatedHindi = '';
//         translatedKannada = '';
//       });
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to generate sentence"),
//             duration: Duration(milliseconds: 1000),
//           ),
//         );
//       }
//     }
//   }

//   Future<void> showTranslation(
//     String langCode,
//     void Function(void Function()) setState,
//   ) async {
//     try {
//       final translated = await translateText(generatedSentence, langCode);
//       setState(() {
//         if (langCode == 'hi') translatedHindi = translated;
//         if (langCode == 'kn') translatedKannada = translated;
//       });
//     } catch (e) {
//       print("❌ Translation failed: $e");
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
//       sentenceToSpeak = translatedKannada.isNotEmpty
//           ? translatedKannada
//           : sentence;
//     } else {
//       langCode = 'en-US';
//     }
//     await flutterTts.setLanguage(langCode);
//     await flutterTts.setSpeechRate(0.5);
//     await flutterTts.speak(sentenceToSpeak);
//   }

//   Future<void> _negateSentence(
//     void Function(void Function()) setState,
//     BuildContext context,
//   ) async {
//     try {
//       final negated =
//           "this is negated sentence"; //await negateSentence(generatedSentence);
//       setState(() {
//         generatedSentence = negated;
//         translatedHindi = '';
//         translatedKannada = '';
//       });
//       await speakSentence(generatedSentence);
//     } catch (e) {
//       print("❌ Negation failed: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Failed to negate sentence.")));
//     }
//   }

//   Future<void> _makePositiveSentence(
//     void Function(void Function()) setState,
//     BuildContext context,
//   ) async {
//     final modified = await SentenceModifier.toPositive(generatedSentence);
//     if (modified == generatedSentence) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("This sentence is already positive.")),
//       );
//       return;
//     }
//     setState(() {
//       generatedSentence = modified;
//       translatedHindi = '';
//       translatedKannada = '';
//     });
//     await speakSentence(generatedSentence);
//   }

//   // =======================================================================
//   // ================= UI WIDGETS TO DROP IN YOUR SCREEN ===================
//   // =======================================================================

//   Widget buildMainColumn(
//     BuildContext context,
//     void Function(void Function()) setState, {
//     Future<void> Function(String selectedIcon)? onIconTap,
//   }) {
//     return categories.isEmpty
//         ? Center(child: CircularProgressIndicator())
//         : Column(
//             children: [
//               // --- Suggestion input, calls backend as you type
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 child: TextField(
//                   decoration: InputDecoration(
//                     labelText: 'Enter text for icon suggestions',
//                     border: OutlineInputBorder(),
//                   ),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedCategory = null;
//                       matchedIcons = [];
//                       selectedWords.clear();
//                     });
//                     rearrangeIconsFromBackend(value, setState);
//                   },
//                 ),
//               ),
//               // --- Horizontal category selector
//               SizedBox(
//                 height: 110,
//                 child: Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           selectedCategory = 'Favourites';
//                         });
//                       },
//                       child: Container(
//                         width: 80,
//                         margin: const EdgeInsets.only(left: 16, right: 8),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           border: Border.all(
//                             color: selectedCategory == 'Favourites'
//                                 ? Theme.of(context).primaryColor
//                                 : Colors.grey.shade400,
//                             width: 2,
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: selectedCategory == 'Favourites'
//                               ? [
//                                   BoxShadow(
//                                     color: Theme.of(context).primaryColor
//                                         .withAlpha((0.15 * 255).toInt()),
//                                     blurRadius: 6,
//                                     offset: Offset(0, 2),
//                                   ),
//                                 ]
//                               : [],
//                         ),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.star, color: Colors.amber, size: 36),
//                             SizedBox(height: 8),
//                             Text(
//                               'Favourites',
//                               style: TextStyle(
//                                 fontWeight: selectedCategory == 'Favourites'
//                                     ? FontWeight.bold
//                                     : FontWeight.normal,
//                                 color: selectedCategory == 'Favourites'
//                                     ? Theme.of(context).primaryColor
//                                     : Colors.black,
//                                 fontSize: 13,
//                               ),
//                               textAlign: TextAlign.center,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: ListView.separated(
//                         scrollDirection: Axis.horizontal,
//                         padding: const EdgeInsets.only(right: 16),
//                         itemCount: categories.length,
//                         separatorBuilder: (context, index) =>
//                             SizedBox(width: 12),
//                         itemBuilder: (context, index) {
//                           final category = categories[index];
//                           final isSelected =
//                               selectedCategory == category.category;
//                           return GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 selectedCategory = category.category;
//                                 matchedIcons = [];
//                               });
//                             },
//                             child: Container(
//                               width: 80,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 border: Border.all(
//                                   color: isSelected
//                                       ? Theme.of(context).primaryColor
//                                       : Colors.grey.shade400,
//                                   width: 2,
//                                 ),
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: isSelected
//                                     ? [
//                                         BoxShadow(
//                                           color: Theme.of(context).primaryColor
//                                               .withAlpha((0.15 * 255).toInt()),
//                                           blurRadius: 6,
//                                           offset: Offset(0, 2),
//                                         ),
//                                       ]
//                                     : [],
//                               ),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   SizedBox(
//                                     width: 40,
//                                     height: 40,
//                                     child: Image.asset(
//                                       category.image,
//                                       fit: BoxFit.contain,
//                                     ),
//                                   ),
//                                   SizedBox(height: 8),
//                                   Text(
//                                     category.category,
//                                     style: TextStyle(
//                                       fontWeight: isSelected
//                                           ? FontWeight.bold
//                                           : FontWeight.normal,
//                                       color: isSelected
//                                           ? Theme.of(context).primaryColor
//                                           : Colors.black,
//                                       fontSize: 13,
//                                     ),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 10),
//               // --- Icon grid: priority order is matchedIcons, favourites, or selected category
//               if (matchedIcons.isNotEmpty)
//                 Expanded(
//                   child: GridView.builder(
//                     padding: EdgeInsets.symmetric(horizontal: 12),
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       mainAxisSpacing: 8,
//                       crossAxisSpacing: 8,
//                     ),
//                     itemCount: matchedIcons.length,
//                     itemBuilder: (context, index) {
//                       final icon = matchedIcons[index];
//                       final isSelected = selectedWords.contains(icon.word);
//                       return GestureDetector(
//                         onTap: () {
//                           toggleSelection(icon.word, setState, context);
//                           if (onIconTap != null) onIconTap(icon.word);
//                         },
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             border: Border.all(
//                               color: isSelected
//                                   ? Colors.green
//                                   : Colors.grey.shade400,
//                               width: 2,
//                             ),
//                             boxShadow: isSelected
//                                 ? [
//                                     BoxShadow(
//                                       color: Colors.greenAccent.withOpacity(
//                                         0.3,
//                                       ),
//                                       blurRadius: 6,
//                                       offset: Offset(0, 4),
//                                     ),
//                                   ]
//                                 : [],
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: EdgeInsets.all(6),
//                           child: Stack(
//                             children: [
//                               Column(
//                                 children: [
//                                   Expanded(
//                                     child: Image.asset(
//                                       icon.image,
//                                       errorBuilder:
//                                           (context, error, stackTrace) {
//                                             return Icon(
//                                               Icons.broken_image,
//                                               size: 36,
//                                               color: Colors.grey,
//                                             );
//                                           },
//                                     ),
//                                   ),
//                                   Text(
//                                     icon.word,
//                                     style: TextStyle(fontSize: 12),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ],
//                               ),
//                               Positioned(
//                                 top: 0,
//                                 right: 0,
//                                 child: IconButton(
//                                   icon: Icon(
//                                     pinnedIcons.contains(icon.word)
//                                         ? Icons.star
//                                         : Icons.star_border,
//                                     color: Colors.amber,
//                                     size: 20,
//                                   ),
//                                   padding: EdgeInsets.zero,
//                                   constraints: BoxConstraints(),
//                                   onPressed: () =>
//                                       togglePin(icon.word, setState),
//                                   tooltip: pinnedIcons.contains(icon.word)
//                                       ? 'Unpin from Favourites'
//                                       : 'Pin to Favourites',
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 )
//               else if (selectedCategory == 'Favourites')
//                 Expanded(
//                   child: GridView.builder(
//                     padding: EdgeInsets.symmetric(horizontal: 12),
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       mainAxisSpacing: 8,
//                       crossAxisSpacing: 8,
//                     ),
//                     itemCount: favouritesCategoryIcons.length,
//                     itemBuilder: (context, index) {
//                       final iconWord = favouritesCategoryIcons[index];
//                       final icon = categories
//                           .expand((cat) => cat.items)
//                           .firstWhere(
//                             (item) => item.word == iconWord,
//                             orElse: () => IconItem(
//                               word: iconWord,
//                               image:
//                                   'assets/icons/core_vocab_places/default.png',
//                               name: 'Default Name',
//                               desc: 'No description available',
//                               embedding: [],
//                             ),
//                           );
//                       if (icon.image == 'assets/default.png' ||
//                           icon.image ==
//                               'assets/icons/core_vocab_places/default.png') {
//                         return SizedBox.shrink();
//                       }
//                       final isSelected = selectedWords.contains(icon.word);
//                       return GestureDetector(
//                         onTap: () =>
//                             toggleSelection(icon.word, setState, context),
//                         child: AnimatedContainer(
//                           duration: Duration(milliseconds: 300),
//                           padding: EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             border: Border.all(
//                               color: isSelected
//                                   ? Colors.green
//                                   : Colors.grey.shade400,
//                               width: 2,
//                             ),
//                             boxShadow: isSelected
//                                 ? [
//                                     BoxShadow(
//                                       color: Colors.greenAccent.withOpacity(
//                                         0.3,
//                                       ),
//                                       blurRadius: 6,
//                                       offset: Offset(0, 4),
//                                     ),
//                                   ]
//                                 : [],
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Stack(
//                             children: [
//                               Column(
//                                 children: [
//                                   Expanded(child: Image.asset(icon.image)),
//                                   Text(
//                                     icon.word,
//                                     style: TextStyle(fontSize: 12),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ],
//                               ),
//                               Positioned(
//                                 top: 0,
//                                 right: 0,
//                                 child: IconButton(
//                                   icon: Icon(
//                                     pinnedIcons.contains(icon.word)
//                                         ? Icons.star
//                                         : Icons.star_border,
//                                     color: Colors.amber,
//                                     size: 20,
//                                   ),
//                                   padding: EdgeInsets.zero,
//                                   constraints: BoxConstraints(),
//                                   onPressed: () =>
//                                       togglePin(icon.word, setState),
//                                   tooltip: pinnedIcons.contains(icon.word)
//                                       ? 'Unpin from Favourites'
//                                       : 'Pin to Favourites',
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 )
//               else if (selectedCategory != null)
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
//                       final selectedCat = categories.firstWhere(
//                         (cat) => cat.category == selectedCategory,
//                       );
//                       List<IconItem> iconList = List.from(selectedCat.items);
//                       iconList.sort((a, b) {
//                         final aIndex = iconPriorityList.indexOf(
//                           a.word.toLowerCase(),
//                         );
//                         final bIndex = iconPriorityList.indexOf(
//                           b.word.toLowerCase(),
//                         );
//                         if (aIndex == -1 && bIndex == -1) return 0;
//                         if (aIndex == -1) return 1;
//                         if (bIndex == -1) return -1;
//                         return aIndex.compareTo(bIndex);
//                       });
//                       final icon = iconList[index];
//                       final isSelected = selectedWords.contains(icon.word);
//                       return GestureDetector(
//                         onTap: () =>
//                             toggleSelection(icon.word, setState, context),
//                         child: AnimatedContainer(
//                           duration: Duration(milliseconds: 300),
//                           padding: EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             border: Border.all(
//                               color: isSelected
//                                   ? Colors.green
//                                   : Colors.grey.shade400,
//                               width: 2,
//                             ),
//                             boxShadow: isSelected
//                                 ? [
//                                     BoxShadow(
//                                       color: Colors.greenAccent.withOpacity(
//                                         0.3,
//                                       ),
//                                       blurRadius: 6,
//                                       offset: Offset(0, 4),
//                                     ),
//                                   ]
//                                 : [],
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Stack(
//                             children: [
//                               Column(
//                                 children: [
//                                   Expanded(child: Image.asset(icon.image)),
//                                   Text(
//                                     icon.word,
//                                     style: TextStyle(fontSize: 12),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ],
//                               ),
//                               Positioned(
//                                 top: 0,
//                                 right: 0,
//                                 child: IconButton(
//                                   icon: Icon(
//                                     pinnedIcons.contains(icon.word)
//                                         ? Icons.star
//                                         : Icons.star_border,
//                                     color: Colors.amber,
//                                     size: 20,
//                                   ),
//                                   padding: EdgeInsets.zero,
//                                   constraints: BoxConstraints(),
//                                   onPressed: () =>
//                                       togglePin(icon.word, setState),
//                                   tooltip: pinnedIcons.contains(icon.word)
//                                       ? 'Unpin from Favourites'
//                                       : 'Pin to Favourites',
//                                 ),
//                               ),
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

//   Widget buildBottomBar(
//     BuildContext context,
//     void Function(void Function()) setState,
//   ) {
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
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 8,
//                 offset: Offset(0, -2),
//               ),
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
//                                 final icon = categories
//                                     .expand((cat) => cat.items)
//                                     .firstWhere(
//                                       (item) => item.word == word,
//                                       orElse: () => IconItem(
//                                         word: word,
//                                         image:
//                                             'assets/icons/core_vocab_places/default.png',
//                                         name: 'Default Name',
//                                         desc: 'No description available',
//                                         embedding: [],
//                                       ),
//                                     );
//                                 return Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 4.0,
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       Image.asset(
//                                         icon.image,
//                                         width: 36,
//                                         height: 36,
//                                         errorBuilder:
//                                             (context, error, stackTrace) {
//                                               return Icon(
//                                                 Icons.broken_image,
//                                                 size: 36,
//                                                 color: Colors.grey,
//                                               );
//                                             },
//                                       ),
//                                       Text(
//                                         word,
//                                         style: TextStyle(fontSize: 10),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () {
//                             setState(() {
//                               if (selectedWords.isNotEmpty) {
//                                 selectedWords.removeLast();
//                                 generateSentenceFromSelected(setState, context);
//                               } else {
//                                 generatedSentence = '';
//                                 translatedHindi = '';
//                                 translatedKannada = '';
//                               }
//                             });
//                           },
//                           icon: Icon(Icons.backspace, color: Colors.red),
//                           tooltip: 'Remove last icon',
//                         ),
//                       ],
//                     ),
//                   ),
//                 if (suggestedIconWords.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 12.0),
//                     child: SizedBox(
//                       height: 60,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: suggestedIconWords.length,
//                         itemBuilder: (context, index) {
//                           final word = suggestedIconWords[index];
//                           final icon = categories
//                               .expand((c) => c.items)
//                               .firstWhere(
//                                 (item) =>
//                                     item.word.toLowerCase() ==
//                                     word.toLowerCase(),
//                                 orElse: () => IconItem(
//                                   word: word,
//                                   image:
//                                       'assets/icons/core_vocab_places/default.png',
//                                   name: '',
//                                   desc: '',
//                                   embedding: [],
//                                 ),
//                               );
//                           return GestureDetector(
//                             onTap: () {
//                               toggleSelection(word, setState, context);
//                               rearrangeIconsBySentence(
//                                 generatedSentence,
//                                 setState,
//                               );
//                               generateSentenceFromSelected(setState, context);
//                             },
//                             child: Padding(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 4.0,
//                               ),
//                               child: Column(
//                                 children: [
//                                   Image.asset(
//                                     icon.image,
//                                     width: 36,
//                                     height: 36,
//                                   ),
//                                   Text(word, style: TextStyle(fontSize: 10)),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 if (generatedSentence.isNotEmpty)
//                   Column(
//                     children: [
//                       Text(
//                         "💬 $generatedSentence",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             IconButton(
//                               onPressed: () =>
//                                   _makePositiveSentence(setState, context),
//                               icon: Text('😊', style: TextStyle(fontSize: 24)),
//                               tooltip: 'Make Positive',
//                             ),
//                             SizedBox(width: 16),
//                             IconButton(
//                               onPressed: () async =>
//                                   await _negateSentence(setState, context),
//                               icon: Text('😞', style: TextStyle(fontSize: 24)),
//                               tooltip: 'Make Negative',
//                             ),
//                           ],
//                         ),
//                       ),
//                       if (translatedHindi.isNotEmpty)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 6.0),
//                           child: Text(
//                             "🇮🇳 Hindi: $translatedHindi",
//                             style: TextStyle(
//                               fontSize: 15,
//                               color: Colors.deepOrange,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       if (translatedKannada.isNotEmpty)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 4.0),
//                           child: Text(
//                             "🇮🇳 Kannada: $translatedKannada",
//                             style: TextStyle(
//                               fontSize: 15,
//                               color: Colors.indigo,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       SizedBox(height: 10),
//                     ],
//                   ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
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
//                       DropdownMenuItem(
//                         value: 'en',
//                         child: Text("🔊 Speak (English)"),
//                       ),
//                       DropdownMenuItem(
//                         value: 'hi',
//                         child: Text("🔊 Speak (Hindi)"),
//                       ),
//                       DropdownMenuItem(
//                         value: 'kn',
//                         child: Text("🔊 Speak (Kannada)"),
//                       ),
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

import '../models/icon_item.dart';
import '../models/icon_category.dart';
import '../utils/icon_suggestion.dart';
import '../utils/sentence_modifier.dart';
import '../services/sentence_service.dart';
import 'falling_icon.dart';

class HomeController {
  late TickerProvider tickerProvider;

  // Core data
  List<IconCategory> categories = [];
  List<IconItem> matchedIcons = [];
  List<IconSuggestion> suggestions = [];
  List<FallingIcon> fallingIcons = [];
  List<String> iconPriorityList = [];
  List<String> selectedWords = [];

  // Favourites / recently used state
  List<String> pinnedIcons = [];
  List<String> recentlyUsedIcons = [];
  final int maxRecentlyUsed = 10;

  List<String> get favouritesCategoryIcons {
    final combined = List<String>.from(pinnedIcons);
    for (var icon in recentlyUsedIcons) {
      if (!combined.contains(icon)) combined.add(icon);
    }
    return combined;
  }

  // Suggestions
  List<String> suggestedIconWords = [];

  // UI/display state
  String generatedSentence = '';
  String translatedHindi = '';
  String translatedKannada = '';
  String? selectedCategory;
  String selectedSpeechLang = 'en';
  int iconFallCount = 0;

  TextEditingController userSentenceController = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();

  // ---------- Helpers ----------

  List<IconItem> parseIconItems(String jsonString) {
    final data = json.decode(jsonString) as List;
    return data.map((e) => IconItem.fromJson(e)).toList();
  }

  List<IconItem> getDefaultIcons() {
    return categories.isNotEmpty
        ? categories.expand((c) => c.items).take(20).toList()
        : [];
  }

  // ---------- Initialization ----------

  Future<void> loadSuggestionsJsonl() async {
    final data = await rootBundle.loadString('assets/suggestions.jsonl');
    final lines = data.split('\n').where((line) => line.trim().isNotEmpty);
    suggestions = lines.map((line) {
      final jsonLine = json.decode(line);
      return IconSuggestion.fromJson(jsonLine);
    }).toList();
  }

  Future<void> loadIconData() async {
    final data = await rootBundle.loadString('assets/icon_categories.json');
    final jsonList = jsonDecode(data);
    categories = jsonList
        .map<IconCategory>((category) => IconCategory.fromJson(category))
        .toList();
  }

  Future<void> init(TickerProvider provider) async {
    tickerProvider = provider;
    await loadIconData();
    await loadSuggestionsJsonl();
  }

  // ---------- Selection / Favourites logic ----------

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
    if (wasAdded) {
      generateSentenceFromSelected(setState, context);
      rearrangeIconsBySentence(generatedSentence, setState); // ← ADD THIS LINE
    }
  }

  void togglePin(String iconWord, void Function(void Function()) setState) {
    setState(() {
      if (pinnedIcons.contains(iconWord)) {
        pinnedIcons.remove(iconWord);
      } else {
        pinnedIcons.add(iconWord);
      }
    });
  }

  void updateRecentlyUsed(String iconWord) {
    if (!pinnedIcons.contains(iconWord)) {
      recentlyUsedIcons.remove(iconWord);
      recentlyUsedIcons.insert(0, iconWord);
      if (recentlyUsedIcons.length > maxRecentlyUsed) {
        recentlyUsedIcons.removeLast();
      }
    }
  }

  void _startFallingIcon(String word, void Function(void Function()) setState) {
    final icon = categories
        .expand((cat) => cat.items)
        .firstWhere(
          (item) => item.word == word,
          orElse: () => IconItem(
            word: word,
            name: 'Default Name',
            desc: 'No description found',
            image: 'assets/icons/core_vocab_places/default.png',
            embedding: [],
          ),
        );
    final falling = FallingIcon(
      key: UniqueKey(),
      imagePath: icon.image,
      startX: 40.0 + (iconFallCount % 6) * 60.0,
    );
    fallingIcons.add(falling);
    iconFallCount++;
    Future.delayed(Duration(milliseconds: 1200), () {
      setState(() {
        fallingIcons.removeWhere((f) => f.key == falling.key);
      });
    });
  }

  // ---------- Backend/UI/AI Features ----------

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

  Future<void> rearrangeIconsFromBackend(
    String sentence,
    void Function(void Function()) setState,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("http://10.30.200.179:5000/rearrange_icons"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"sentence": sentence}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> icons = data["icons"];
        print("🎯 Backend icons: $icons");

        matchedIcons = [];
        for (var iconJson in icons) {
          try {
            final icon = IconItem.fromJson(iconJson);
            matchedIcons.add(icon);
          } catch (e) {
            print("🚨 Bad iconJson: $iconJson");
            print("❌ Error parsing: $e");
          }
        }
        setState(() {});
      } else {
        print("❌ Backend responded with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error in rearrangeIconsFromBackend: $e");
    }
  }

  Future<void> fetchIconsBySentence(String? sentence) async {
    if (sentence == null || sentence.trim().isEmpty) {
      print("⚠️ Sentence is null or empty. Skipping request.");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.30.200.179:5000/rearrange_icons'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sentence': sentence}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final icons = data['icons'];
        print("✅ Got ${icons.length} icons");
        // update your icon display logic here
      } else {
        print("❌ Backend error: ${response.body}");
      }
    } catch (e) {
      print("❌ Failed to rearrange icons: $e");
    }
  }

  // ---------- TTS / Generation / Translation ----------

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

  Future<void> showTranslation(
    String langCode,
    void Function(void Function()) setState,
  ) async {
    try {
      final translated = await translateText(generatedSentence, langCode);
      setState(() {
        if (langCode == 'hi') translatedHindi = translated;
        if (langCode == 'kn') translatedKannada = translated;
      });
    } catch (e) {
      print("❌ Translation failed: $e");
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

  Future<void> _negateSentence(
    void Function(void Function()) setState,
    BuildContext context,
  ) async {
    try {
      final negated =
          "this is negated sentence"; //await negateSentence(generatedSentence);
      setState(() {
        generatedSentence = negated;
        translatedHindi = '';
        translatedKannada = '';
      });
      await speakSentence(generatedSentence);
    } catch (e) {
      print("❌ Negation failed: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to negate sentence.")));
    }
  }

  Future<void> _makePositiveSentence(
    void Function(void Function()) setState,
    BuildContext context,
  ) async {
    final modified = await SentenceModifier.toPositive(generatedSentence);
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
    await speakSentence(generatedSentence);
  }

  // =======================================================================
  // ================= UI WIDGETS TO DROP IN YOUR SCREEN ===================
  // =======================================================================

  Widget buildMainColumn(
    BuildContext context,
    void Function(void Function()) setState, {
    Future<void> Function(String selectedIcon)? onIconTap,
  }) {
    return categories.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              // --- Location/suggestion input (teammate's version)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Enter location (e.g., PES University)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = null;
                      matchedIcons = [];
                      selectedWords.clear();
                    });
                    rearrangeIconsFromBackend(value, setState);
                  },
                ),
              ),
              // --- Horizontal scrollable categories
              SizedBox(
                height: 110,
                child: Row(
                  children: [
                    // Fixed "Favourites" category
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = 'Favourites';
                          matchedIcons = [];
                        });
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(left: 16, right: 8),
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
                    // Scrollable ordinary categories
                    Expanded(
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(right: 16),
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
                                matchedIcons = [];
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
              // --- Icon grid: priority order is matchedIcons, favourites, or selected category
              if (matchedIcons.isNotEmpty)
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: matchedIcons.length,
                    itemBuilder: (context, index) {
                      final icon = matchedIcons[index];
                      final isSelected = selectedWords.contains(icon.word);
                      return GestureDetector(
                        onTap: () {
                          toggleSelection(icon.word, setState, context);
                          if (onIconTap != null) onIconTap(icon.word);
                        },
                        child: Container(
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
                                      color: Colors.greenAccent.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 6,
                                      offset: Offset(0, 4),
                                    ),
                                  ]
                                : [],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(6),
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  Expanded(
                                    child: Image.asset(
                                      icon.image,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.broken_image,
                                              size: 36,
                                              color: Colors.grey,
                                            );
                                          },
                                    ),
                                  ),
                                  Text(
                                    icon.word,
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
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
              else if (selectedCategory == 'Favourites')
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                              name: 'Default Name',
                              desc: 'No description available',
                              image:
                                  'assets/icons/core_vocab_places/default.png',
                              embedding: [],
                            ),
                          );

                      final isSelected = selectedWords.contains(icon.word);
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
                                      color: Colors.greenAccent.withOpacity(
                                        0.3,
                                      ),
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
                                    child: Image.asset(
                                      icon.image,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.broken_image,
                                              size: 36,
                                              color: Colors.grey,
                                            );
                                          },
                                    ),
                                  ),
                                  Text(
                                    icon.word,
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
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
              else if (selectedCategory != null)
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: categories
                        .firstWhere((cat) => cat.category == selectedCategory)
                        .items
                        .length,
                    itemBuilder: (context, index) {
                      final selectedCat = categories.firstWhere(
                        (cat) => cat.category == selectedCategory,
                      );
                      List<IconItem> iconList = List.from(selectedCat.items);

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
                      final isSelected = selectedWords.contains(icon.word);
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
                                      color: Colors.greenAccent.withOpacity(
                                        0.3,
                                      ),
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
                                    child: Image.asset(
                                      icon.image,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.broken_image,
                                              size: 36,
                                              color: Colors.grey,
                                            );
                                          },
                                    ),
                                  ),
                                  Text(
                                    icon.word,
                                    style: TextStyle(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
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
                                        name: 'Default Name',
                                        desc: 'No description available',
                                        image:
                                            'assets/icons/core_vocab_places/default.png',
                                        embedding: [],
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
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Icon(
                                                Icons.broken_image,
                                                size: 36,
                                                color: Colors.grey,
                                              );
                                            },
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
                if (suggestedIconWords.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: suggestedIconWords.length,
                        itemBuilder: (context, index) {
                          final word = suggestedIconWords[index];
                          final icon = categories
                              .expand((c) => c.items)
                              .firstWhere(
                                (item) =>
                                    item.word.toLowerCase() ==
                                    word.toLowerCase(),
                                orElse: () => IconItem(
                                  word: word,
                                  name: '',
                                  desc: '',
                                  image:
                                      'assets/icons/core_vocab_places/default.png',
                                  embedding: [],
                                ),
                              );
                          return GestureDetector(
                            onTap: () {
                              toggleSelection(word, setState, context);
                              rearrangeIconsBySentence(
                                generatedSentence,
                                setState,
                              );
                              generateSentenceFromSelected(setState, context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4.0,
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    icon.image,
                                    width: 36,
                                    height: 36,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.broken_image,
                                        size: 36,
                                        color: Colors.grey,
                                      );
                                    },
                                  ),
                                  Text(word, style: TextStyle(fontSize: 10)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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

                      // 😊😞 Emoji buttons
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
                              onPressed: () async =>
                                  await _negateSentence(setState, context),
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
