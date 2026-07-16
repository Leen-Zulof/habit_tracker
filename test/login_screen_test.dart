// test/login_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/login_screen.dart';

void main() {
  test('accepts a registered user even when the entered values include extra spaces', () {
    expect(
      isValidLoginCredentials(
        enteredUsername: '  testuser  ',
        enteredPassword: 'password123',
        storedUsername: 'testuser',
        storedPassword: 'password123',
      ),
      isTrue,
    );
  });

  test('rejects credentials when no stored account exists', () {
    expect(
      isValidLoginCredentials(
        enteredUsername: 'testuser',
        enteredPassword: 'password123',
        storedUsername: null,
        storedPassword: null,
      ),
      isFalse,
    );
  });
}
