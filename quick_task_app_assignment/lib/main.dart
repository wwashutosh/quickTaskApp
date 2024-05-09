import 'package:flutter/material.dart';
import 'package:quick_task_app_assignment/login_page.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final keyApplicationId = 'AJRbklyFu2CiY1lKvWgp2tgfBq3XqYNpkv3HnQ4b';
  final keyClientKey = 'vmGVUTkjqj0CHk5H9aQZA4HZOkJZa0IPezlVAuWD';
  final keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(
    keyApplicationId,
    keyParseServerUrl,
    clientKey: keyClientKey,
    autoSendSessionId: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickTaskApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
