// import 'package:flutter/material.dart';
// import 'widgets/jungle_background.dart';
// import 'widgets/space_background.dart';
// import 'screens/home_screen.dart'; // Make sure this is correct

// void main() => runApp(MyApp());

// enum BackgroundType { jungle, space }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Theme Switcher',
//       home: BackgroundSwitcherScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

// class BackgroundSwitcherScreen extends StatefulWidget {
//   @override
//   _BackgroundSwitcherScreenState createState() => _BackgroundSwitcherScreenState();
// }

// class _BackgroundSwitcherScreenState extends State<BackgroundSwitcherScreen> {
//   BackgroundType _selectedBackground = BackgroundType.jungle;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background preview
//           Positioned.fill(
//             child: _selectedBackground == BackgroundType.jungle
//                 ? JungleBackground()
//                 : SpaceBackground(),
//           ),

//           // Dropdown + Start button
//           SafeArea(
//             child: Align(
//               alignment: Alignment.topLeft,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     DropdownButton<BackgroundType>(
//                       value: _selectedBackground,
//                       dropdownColor: Colors.black87,
//                       iconEnabledColor: Colors.white,
//                       style: TextStyle(color: Colors.white, fontSize: 16),
//                       items: BackgroundType.values.map((type) {
//                         return DropdownMenuItem(
//                           value: type,
//                           child: Text(
//                             type == BackgroundType.jungle ? '🌿 Jungle' : '🌌 Space',
//                           ),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedBackground = value!;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => HomeScreen(
//                               backgroundType: _selectedBackground,
//                             ),
//                           ),
//                         );
//                       },
//                       child: Text(
//                         'Start',
//                         style: TextStyle(color: Colors.black),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // lib/main.dart
// import 'package:flutter/material.dart';
// // import 'screens/login_screen.dart';
// import 'screens/welcome_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Icon Sentence Generator',
//       debugShowCheckedModeBanner: false,
//       home: WelcomeScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; // ✅ Make sure this is imported

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Icon Talker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const WelcomeScreen(), // ✅ THIS LINE IS IMPORTANT
    );
  }
}
