import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'CenterPage.dart';

class RegisterExameData {
  final String doctor;
  final String patient;
  final String equipment;

  RegisterExameData(this.doctor, this.patient, this.equipment);

  Map<String, dynamic> toJson() {
    return {
      'doctor': doctor,
      'patient': patient,
      'equipment': equipment,
    };
  }
}

class RegisterExame extends StatefulWidget {
  @override
  _RegisterExame createState() => _RegisterExame();
}

class _RegisterExame extends State<RegisterExame> {
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();
  bool _isChangingRole = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Exam'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _doctorController,
              decoration: InputDecoration(labelText: 'Doctor Username'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _patientController,
              decoration: InputDecoration(labelText: 'Patient Username'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _equipmentController,
              decoration: InputDecoration(labelText: 'Equipment'),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _isChangingRole ? null : _changeRole,
              child: Text('Register Exame'),
            ),
          ],
        ),
      ),
    );
  }

  void _changeRole() async {
    setState(() {
      _isChangingRole = true;
    });

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

    final changeRoleData = RegisterExameData(
      _doctorController.text,
      _patientController.text,
      _equipmentController.text,
    );

    final response = await http.post(
      Uri.parse('https://aula-123.oa.r.appspot.com/rest/registerExame'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(changeRoleData.toJson()),
    );

    if (response.statusCode == 200) {
      // Exiba uma mensagem de sucesso
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Exame registered successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
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
    } else {
      // Exiba uma mensagem de erro
      final errorMessage = json.decode(response.body)['error'];
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
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

    setState(() {
      _isChangingRole = false;
    });
  }
}
