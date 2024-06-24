import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_3/main_menu_page.dart';

class AuthProvider extends ChangeNotifier {
  final GlobalKey<FormState> formAuthentication = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  String messageError = '';
  final String url = 'http://192.168.1.105:3000'; // Your API base URL

  void changeObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  Future<void> processAuth(BuildContext context, bool isLogin) async {
    final String username = usernameController.text.trim();
    final String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      messageError = 'Please fill in all fields';
      notifyListeners();
      return;
    }

    try {
      var requestModel = {'username': username, 'password': password};
      var response = await Dio().post(
        '$url/${isLogin ? 'login' : 'register'}',
        data: requestModel,
      );

      if (isLogin) {
        handleLoginResponse(context, response);
      } else {
        handleRegisterResponse(context, response);
      }
    } on DioException catch (e) {
      messageError = e.response?.data['error'] ?? 'An error occurred';
      notifyListeners();
    }
  }

  void handleLoginResponse(BuildContext context, Response response) {
    if (response.statusCode == 200 && response.data['message'] == 'Login success') {
      saveUserData(response.data['data']);
      alertAuthSuccess(context, response.data['message']);
    } else {
      alertAuthFailure(context, response.data['message'] ?? 'Login failed');
    }
  }

  void handleRegisterResponse(BuildContext context, Response response) {
    if (response.statusCode == 201 && response.data['message'] == 'User created successfully') {
      alertAuthSuccess(context, response.data['message']);
    } else {
      alertAuthFailure(context, response.data['message'] ?? 'Registration failed');
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', userData['id']);
    await prefs.setString('username', userData['username']);
    await prefs.setString('password', userData['password']);
  }

  Future<void> processLogin(BuildContext context) => processAuth(context, true);
  Future<void> processRegister(BuildContext context) => processAuth(context, false);

  void alertAuthSuccess(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 50),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => navigateToMainMenu(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void alertAuthFailure(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void navigateToMainMenu(BuildContext context) {
    usernameController.clear();
    passwordController.clear();
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainMenuPage()),
    );
  }
}
