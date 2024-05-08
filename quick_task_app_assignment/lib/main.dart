import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:quick_task_app_assignment/task_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final keyApplicationId = 'AJRbklyFu2CiY1lKvWgp2tgfBq3XqYNpkv3HnQ4b';
  final keyClientKey = 'vmGVUTkjqj0CHk5H9aQZA4HZOkJZa0IPezlVAuWD';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RegistrationPage(),
    );
  }
}

class RegistrationPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void doUserRegistration(BuildContext context) async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final user = ParseUser.createUser(username, password, email);
    var response = await user.signUp();
    if (response.success) {
      // Registration successful
      showSuccess(context,
          'Registration successful'); // Implement this function to show a success message
    } else {
      // Registration failed, handle error
      showError(
          'Registration failed: ${response.error?.message}'); // Implement this function to show an error message
    }
  }

  void doUserLogin(BuildContext context) async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    var user = ParseUser(username, password, null);
    var response = await user.login();
    if (response.success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TaskListPage()),
      );
      // Login successful
      showSuccess(context,
          'Login successful'); // Implement this function to show a success message
    } else {
      // Login failed, handle error
      showError(
          'Login failed: ${response.error?.message}'); // Implement this function to show an error message
      showErrorDialog(context, response.error?.message ?? 'Unknown error');
    }
  }

  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Registration / Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => doUserRegistration(context),
              child: Text('Register'),
            ),
            ElevatedButton(
              onPressed: () => doUserLogin(context),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  void showSuccess(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void showError(String message) {
    // Implement this function to show an error message
    print(message);
  }
}
