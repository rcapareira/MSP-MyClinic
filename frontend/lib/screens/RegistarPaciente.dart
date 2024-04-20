import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:apdc_individual/screens/LoginPage.dart';
import 'package:http/http.dart' as http;

class RegistarPaciente extends StatefulWidget {
  const RegistarPaciente({Key? key}) : super(key: key);

  @override
  State<RegistarPaciente> createState() => _RegistarPaciente();
}

class _RegistarPaciente extends State<RegistarPaciente> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildTextField('Username', _usernameController),
                const SizedBox(height: 10),
                _buildTextField('Password', _passwordController,
                    obscureText: true),
                const SizedBox(height: 10),
                _buildTextField(
                    'Confirmar Password', _confirmPasswordController,
                    obscureText: true),
                const SizedBox(height: 10),
                _buildTextField('Email', _emailController,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 10),
                _buildTextField('Nome', _nameController),
                const SizedBox(height: 10),
                _buildTextField('Número', _numberController,
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: const Text('Signup'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Já tem conta? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final data = {
        'username': _usernameController.text,
        'password': _passwordController.text,
        'email': _emailController.text,
        'name': _nameController.text,
        'number': _numberController.text,
        'role': 'pacient',
      };

      final response = await http.post(
        Uri.parse(
            'https://aula-123.oa.r.appspot.com/rest/register'), // Substitua pelo endereço do seu backend
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Manipule o registro bem-sucedido
        setState(() {
          _isSubmitting = false;
          // Limpe os campos do formulário, mostre uma mensagem de sucesso, etc.
        });

        // Exibir caixa de diálogo de sucesso
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Sucesso'),
              content: Text('Usuário registrado com sucesso!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha a caixa de diálogo
                    // Redirecionar para a página de login
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Manipule erros com base no código e no corpo da resposta
        final errorMessage = json.decode(response.body)['error'];
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
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildTextField(String labelText, TextEditingController controller,
      {bool obscureText = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      minLines: 1,
      maxLines: 1,
      decoration: InputDecoration(
        labelText: labelText,
        contentPadding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
    );
  }
}
