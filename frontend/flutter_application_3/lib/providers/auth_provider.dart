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

    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        var requestModel = {'username': username, 'password': password};
        var response = await Dio().post('$url/${isLogin ? 'login' : 'register'}', data: requestModel);

        if ((isLogin && response.statusCode == 200 && response.data['message'] == 'Login Success') ||
            (!isLogin && response.statusCode == 201)) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('id', response.data['data']['id']);
          await prefs.setString('username', response.data['data']['username']);
          alertAuthSuccess(context, '${isLogin ? 'Login' : 'Registration'} Successful');
        } else {
          messageError = response.data['message'] ?? '${isLogin ? 'Login' : 'Registration'} failed';
          notifyListeners();
        }
      } on DioException catch (e) {
        messageError = e.message ?? 'An error occurred';
        notifyListeners();
      }
    } else {
      messageError = 'Please fill in all fields';
      notifyListeners();
    }
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
              Text(
                message,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                usernameController.clear();
                passwordController.clear();
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainMenuPage(),
                  ),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void navigateToMainMenu(BuildContext context) {}
}