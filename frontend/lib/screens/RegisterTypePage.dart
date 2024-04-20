import 'package:flutter/material.dart';
import 'RegistarDoctor.dart';
import 'RegistarPaciente.dart';

class RegisterTypePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Inicial'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistarDoctor()),
                );
              },
              child: Text('Registrar Médico'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistarPaciente()),
                );
              },
              child: Text('Registrar Paciente'),
            ),
          ],
        ),
      ),
    );
  }
}
