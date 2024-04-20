import 'dart:convert';
import 'package:apdc_individual/screens/RegisterTypePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'centerPage.dart';

class LoginData {
  final String username;
  final String password;

  LoginData(this.username, this.password);

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoggingIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _isLoggingIn ? null : _login,
              child: Text('Login'),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterTypePage()),
                );
              },
              child: Text('Don\'t have an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    setState(() {
      _isLoggingIn = true;
    });

    final loginData = LoginData(
      _emailController.text,
      _passwordController.text,
    );

    final url = Uri.parse('https://aula-123.oa.r.appspot.com/rest/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(loginData.toJson()),
      );

      if (response.statusCode == 200) {
        final cookieData = jsonDecode(response.body);

        if (cookieData is Map<String, dynamic>) {
          final cookieJson = jsonEncode(cookieData);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool success = await prefs.setString('cookie', cookieJson);

          if (!success) {
            print('Erro ao armazenar o cookie.');
          } else {
            print('Cookie armazenado: $cookieJson');
            _showCookieDialog(cookieData['value']);
          }
        } else {
          print(
              'Erro: Os dados do cookie não são do tipo Map<String, dynamic>.');
        }
      } else {
        final errorMessage = jsonDecode(response.body)['error'];

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Erro'),
              content: Text(errorMessage),
              actions: [
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
    } catch (error) {
      print('Erro ao fazer login: $error');
    }

    setState(() {
      _isLoggingIn = false;
    });
  }

  void _showCookieDialog(String cookieJson) {
    // Split do cookie por '.'
    List<String> cookieValues = cookieJson.split('.');

    // Atribuição dos valores do cookie aos seus respectivos nomes
    String username = cookieValues[0];
    String iDToken = cookieValues[1];
    String role = cookieValues[2];
    String creationDate = cookieValues[3];
    String expirationDate = cookieValues[4];
    String hashCode = cookieValues[5];

    // Mensagem formatada
    String message =
        'Username: $username\niDToken: $iDToken\nRole: $role\nCreation Date: $creationDate\nExpiration Date: $expirationDate\nHash Code: $hashCode';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cookie Armazenado'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CenterPage()),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
