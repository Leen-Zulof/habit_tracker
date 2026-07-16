// login_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_storage.dart';
import 'habit_tracker_screen.dart';
import 'register_screen.dart';

Map<String, String?> getStoredCredentials({
  String? currentUserJson,
  String? registeredUsername,
  String? registeredPassword,
  String? lastRegisteredUsername,
  String? lastRegisteredPassword,
  String? username,
  String? password,
}) {
  if (currentUserJson != null) {
    try {
      final decoded = jsonDecode(currentUserJson);
      if (decoded is Map<String, dynamic>) {
        return {
          'username': decoded['username']?.toString(),
          'password': decoded['password']?.toString(),
        };
      }
    } catch (_) {
      // Ignore malformed JSON and fall back to the individual keys.
    }
  }

  return {
    'username': registeredUsername ?? lastRegisteredUsername ?? username,
    'password': registeredPassword ?? lastRegisteredPassword ?? password,
  };
}

bool isValidLoginCredentials({
  required String enteredUsername,
  required String enteredPassword,
  String? storedUsername,
  String? storedPassword,
}) {
  final normalizedEnteredUsername = enteredUsername.trim().toLowerCase();
  final normalizedEnteredPassword = enteredPassword.trim();
  final normalizedStoredUsername = storedUsername?.trim().toLowerCase();
  final normalizedStoredPassword = storedPassword?.trim();

  return normalizedEnteredUsername == normalizedStoredUsername &&
      normalizedEnteredPassword == normalizedStoredPassword;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _loadedUserSummary = 'No saved user';

  @override
  void initState() {
    super.initState();
    _loadSavedUser();
  }

  Future<void> _loadSavedUser() async {
    final storedCredentials = await AuthStorage.loadCredentials();

    if (!mounted) return;
    setState(() {
      _loadedUserSummary =
          'Saved user: ${storedCredentials['username']} / ${storedCredentials['password']}';
    });
  }

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    final storedCredentials = await AuthStorage.loadCredentials();

    final storedUsername = storedCredentials['username'];
    final storedPassword = storedCredentials['password'];

    if (isValidLoginCredentials(
      enteredUsername: username,
      enteredPassword: password,
      storedUsername: storedUsername,
      storedPassword: storedPassword,
    )) {
      final savedName = prefs.getString('name') ?? username;
      final savedAge = prefs.getDouble('age') ?? 25;
      final savedCountry = prefs.getString('country') ?? 'United States';

      await prefs.setString('name', savedName);
      await prefs.setString('username', username);
      await prefs.setString('password', password);
      await prefs.setString('registeredUsername', username);
      await prefs.setString('registeredPassword', password);
      await prefs.setString(
        'currentUser',
        jsonEncode({
          'name': savedName,
          'username': username,
          'password': password,
          'age': savedAge,
          'country': savedCountry,
        }),
      );
      await prefs.setDouble('age', savedAge);
      await prefs.setString('country', savedCountry);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HabitTrackerScreen(username: username),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: "The username or password was incorrect",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Habitt',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  _loadedUserSummary,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      prefixIcon:
                          Icon(Icons.email, color: Colors.blue.shade700),
                      hintText: 'Enter Username',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
                      hintText: 'Enter Password',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Logic for forgot password can be added here
                    },
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 15),
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'or',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  RegisterScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 70, vertical: 15),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}