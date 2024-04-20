import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apdc_individual/screens/CenterPage.dart';

class RegisterCheckInData {
  final String doctor;
  final String patient;
  final String date;
  final String time;

  RegisterCheckInData(this.doctor, this.patient, this.date, this.time);

  Map<String, dynamic> toJson() {
    return {
      'doctor': doctor,
      'patient': patient,
      'date': date,
      'time': time,
    };
  }
}

class CheckInPage extends StatefulWidget {
  @override
  _CheckInPage createState() => _CheckInPage();
}

class _CheckInPage extends State<CheckInPage> {
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  bool _isChangingState = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check In'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _doctorController,
              decoration: InputDecoration(labelText: 'doctor'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _patientController,
              decoration: InputDecoration(labelText: 'patient'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: 'date'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _timeController,
              decoration: InputDecoration(labelText: 'time'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isChangingState ? null : _changeState,
              child: Text('Registe Appointment'),
            ),
          ],
        ),
      ),
    );
  }

  void _changeState() async {
    setState(() {
      _isChangingState = true;
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

    final doctor = _doctorController.text;
    final patient = _patientController.text;
    final date = _dateController.text;
    final time = _timeController.text;

    final changeStateData = RegisterCheckInData(doctor, patient, date, time);

    final response = await http.post(
      Uri.parse('https://aula-123.oa.r.appspot.com/rest/checkin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(changeStateData.toJson()),
    );

    if (response.statusCode == 200) {
      // Exiba uma mensagem de sucesso
      _showSuccessDialog('Check In successful');
    } else {
      // Exiba uma mensagem de erro
      final errorMessage = json.decode(response.body)['error'];
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isChangingState = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
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
  }
}
