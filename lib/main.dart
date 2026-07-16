// main.dart
import 'package:flutter/material.dart';

import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}