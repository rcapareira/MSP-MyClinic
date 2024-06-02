import 'package:apdc_individual/screens/CheckInPage.dart';
import 'package:apdc_individual/screens/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'ListHistoricConsultPage.dart';
import 'RegisterExame.dart';
import 'RegistarAppointment.dart';
import 'StockManagementPage.dart'; // Import the new Stock Management page

import 'dart:convert';

class LogoutData {
  final String cookie;

  LogoutData(this.cookie);

  Map<String, dynamic> toJson() {
    return {
      'cookie': cookie,
    };
  }
}

class CenterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(context, 'Histórico de Consultas', ListUserPage()),
              SizedBox(height: 16),
              _buildButton(context, 'Register Exam', RegisterExame()),
              SizedBox(height: 16),
              _buildButton(
                  context, 'Register Appointment', RegistarAppointment()),
              SizedBox(height: 16),
              _buildButton(context, 'Check In', CheckInPage()),
              SizedBox(height: 16),
              _buildButton(context, 'Stock Management', StockManagementPage()),
              SizedBox(height: 16),
              _buildButton(context, 'Logout', Container(), logout: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, Widget nextPage,
      {bool logout = false}) {
    return ElevatedButton(
      onPressed: () async {
        if (logout) {
          await _logout(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => nextPage),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        child: Text(label),
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenValue = prefs.getString('cookie');
    String cookie = '';
    if (tokenValue != null && tokenValue.isNotEmpty) {
      try {
        Map<String, dynamic> cookieMap = jsonDecode(tokenValue);
        cookie = cookieMap['value'] ?? '';
      } catch (e) {
        print('Erro ao decodificar o JSON do cookie: $e');
      }
    }

    final response = await http.post(
      Uri.parse('https://aula-123.oa.r.appspot.com/rest/logout'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(LogoutData(cookie).toJson()),
    );

    if (response.statusCode == 200) {
      // Clear saved cookie
      await prefs.remove('cookie');
      print('Logout successful');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      // Handle error
      print('Logout failed: ${response.body}');
    }
  }
}
