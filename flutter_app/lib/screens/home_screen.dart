// // lib/screens/home_screen.dart
// import 'package:flutter/material.dart';
// import '../main.dart';
// import '../models/background_type.dart';
// import '../widgets/jungle_background.dart';
// import '../widgets/space_background.dart';
// import '../screens/home_controller.dart';
// import '../screens/falling_icon.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../models/icon_item.dart';

// // import 'package:flutter_app/models/icon_item.dart'; // Adjust path as needed

// class HomeScreen extends StatefulWidget {
//   final BackgroundType backgroundType;
//   const HomeScreen({Key? key, required this.backgroundType}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
//   final HomeController controller = HomeController();
//   List<IconItem> matchedIcons = []; // ✅ Add this line

//   @override
//   void initState() {
//     super.initState();
//     controller.init(this);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("🧠 Icon Sentence Generator")),
//       body: Stack(
//         children: [
//           widget.backgroundType == BackgroundType.space
//               ? SpaceBackground()
//               : JungleBackground(),
//           controller.buildMainColumn(context, setState),
//           ...controller.fallingIcons,
//         ],
//       ),
//       bottomNavigationBar: controller.buildBottomBar(context, setState),
//     );
//   }

//   Future<void> rearrangeIconsBySentence(String sentence) async {
//     try {
//       final response = await http.post(
//         Uri.parse(
//           "http://127.0.0.1:5000/rearrange_icons",
//         ), // use local IP if on phone
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"sentence": sentence}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List<dynamic> icons = data["icons"];

//         setState(() {
//           matchedIcons = icons.map((iconJson) {
//             return IconItem.fromJson(iconJson);
//           }).toList();
//         });
//       } else {
//         print("Backend error: ${response.body}");
//       }
//     } catch (e) {
//       print("Failed to rearrange icons: $e");
//     }
//   }
// }


// ///////////////////////////////////////////////////

// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/background_type.dart';
import '../widgets/jungle_background.dart';
import '../widgets/space_background.dart';
import 'home_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/icon_item.dart';

class HomeScreen extends StatefulWidget {
  final BackgroundType backgroundType;
  const HomeScreen({Key? key, required this.backgroundType}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final HomeController controller = HomeController();
  List<IconItem> matchedIcons = [];

  bool _isLoading = true;

  @override
  void initState() {
  super.initState();

  controller.init(this).then((_) {
    setState(() {
      _isLoading = false;
    });
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("🧠 Icon Sentence Generator")),
      body: Stack(
        children: [
          widget.backgroundType == BackgroundType.space
              ?  SpaceBackground()
              :  JungleBackground(),

          // 🌀 Loading indicator until data is ready
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            controller.buildMainColumn(context, setState),
            ...controller.fallingIcons,
          ],
        ],
      ),
      bottomNavigationBar:
          _isLoading ? null : controller.buildBottomBar(context, setState),
    );
  }

  Future<void> rearrangeIconsBySentence(String sentence) async {
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:5000/rearrange_icons"),
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
        print("❌ Backend error: ${response.body}");
      }
    } catch (e) {
      print("❌ Failed to rearrange icons: $e");
    }
  }
}
