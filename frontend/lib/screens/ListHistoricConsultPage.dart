import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListUserPage extends StatefulWidget {
  @override
  _ListUserPageState createState() => _ListUserPageState();
}

class _ListUserPageState extends State<ListUserPage> {
  List<Map<String, dynamic>> _consultationList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateConsultationList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Consultas'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _consultationList.isNotEmpty
              ? ListView.builder(
                  itemCount: _consultationList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildText(
                                'Doutor', _consultationList[index]['doctor']),
                            _buildText('Especialidade',
                                _consultationList[index]['specialty']),
                            _buildText(
                                'Data', _consultationList[index]['date']),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Center(child: Text('Nenhuma consulta encontrada')),
    );
  }

  Widget _buildText(String label, String value) {
    return Text('$label: $value');
  }

  void _generateConsultationList() {
    setState(() {
      _isLoading = true;
    });

    List<String> doctors = [
      'Dr. Silva',
      'Dr. Santos',
      'Dr. Pereira',
      'Dr. Costa',
      'Dr. Lima'
    ];
    List<String> specialties = [
      'Cardiologia',
      'Dermatologia',
      'Pediatria',
      'Neurologia',
      'Ortopedia'
    ];
    List<Map<String, dynamic>> consultations = [];

    final random = Random();

    for (int i = 0; i < 10; i++) {
      String doctor = doctors[random.nextInt(doctors.length)];
      String specialty = specialties[random.nextInt(specialties.length)];
      String date = _randomPastDate();

      consultations.add({
        'doctor': doctor,
        'specialty': specialty,
        'date': date,
      });
    }

    setState(() {
      _consultationList = consultations;
      _isLoading = false;
    });
  }

  String _randomPastDate() {
    final random = Random();
    int daysAgo = random.nextInt(365);
    DateTime date = DateTime.now().subtract(Duration(days: daysAgo));
    return '${date.day}/${date.month}/${date.year}';
  }
}
