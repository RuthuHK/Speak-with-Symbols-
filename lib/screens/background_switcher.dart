// lib/screens/background_switcher.dart
import 'package:flutter/material.dart';
import '../models/background_type.dart';
import '../widgets/jungle_background.dart';
import '../widgets/space_background.dart';
import 'home_screen.dart';

class BackgroundSwitcherScreen extends StatefulWidget {
  const BackgroundSwitcherScreen({super.key});

  @override
  State<BackgroundSwitcherScreen> createState() =>
      _BackgroundSwitcherScreenState();
}

class _BackgroundSwitcherScreenState extends State<BackgroundSwitcherScreen> {
  BackgroundType _selectedBackground = BackgroundType.jungle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _selectedBackground == BackgroundType.jungle
                ? JungleBackground()
                : SpaceBackground(),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<BackgroundType>(
                      value: _selectedBackground,
                      dropdownColor: Colors.black87,
                      iconEnabledColor: Colors.white,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      items: BackgroundType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type == BackgroundType.jungle
                                ? '🌿 Jungle'
                                : '🌌 Space',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBackground = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                HomeScreen(backgroundType: _selectedBackground),
                          ),
                        );
                      },
                      child: const Text(
                        'Start',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
