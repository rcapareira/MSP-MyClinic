import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:apdc_individual/screens/LoginPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Chamar o endpoint antes de ir para a página de login

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
