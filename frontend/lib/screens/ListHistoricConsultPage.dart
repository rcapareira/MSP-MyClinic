import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LogoutData {
  final String cookie;

  LogoutData(this.cookie);

  Map<String, dynamic> toJson() {
    return {
      'cookie': cookie,
    };
  }
}

class ListUserPage extends StatefulWidget {
  @override
  _ListUserPageState createState() => _ListUserPageState();
}

class _ListUserPageState extends State<ListUserPage> {
  List<Map<String, dynamic>> _userList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List Users'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _userList.isNotEmpty
              ? ListView.builder(
                  itemCount: _userList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildText(
                                'Username', _userList[index]['username']),
                            _buildText('Role', _userList[index]['role']),
                            _buildText('Email', _userList[index]['email']),
                            _buildText('Name', _userList[index]['name']),
                            _buildText('Number', _userList[index]['number']),
                            _buildText('Profile', _userList[index]['profile']),
                            _buildText('Address', _userList[index]['address']),
                            _buildText(
                                'Occupation', _userList[index]['occupation']),
                            _buildText(
                                'Workplace', _userList[index]['workplace']),
                            _buildText(
                                'Post Code', _userList[index]['postCode']),
                            _buildText('NIF', _userList[index]['nif']),
                            _buildText(
                                'Image Path', _userList[index]['imagePath']),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Center(child: Text('No users found')),
    );
  }

  Widget _buildText(String label, String? value) {
    if (value != null && value.isNotEmpty) {
      return Text('$label: $value');
    } else {
      return SizedBox(); // Return an empty widget if the value is null or empty
    }
  }

  Future<void> _fetchUserList() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenValue = prefs.getString('cookie');

    String cookie = '';
    if (tokenValue != null && tokenValue.isNotEmpty) {
      try {
        Map<String, dynamic> cookieMap = jsonDecode(tokenValue);
        if (cookieMap.containsKey('value')) {
          cookie = cookieMap['value'] as String;
        } else {
          print('Chave "value" não encontrada no mapa do cookie.');
        }
      } catch (e) {
        print('Erro ao decodificar o JSON do cookie: $e');
      }
    } else {
      print('TokenValue é nulo ou vazio.');
    }

    final response = await http.post(
      Uri.parse('https://aula-123.oa.r.appspot.com/rest/list'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'cookie': cookie}),
    );

    if (response.statusCode == 200) {
      if (response.body != null && response.body.isNotEmpty) {
        List<dynamic> responseBody = json.decode(response.body);
        List<Map<String, dynamic>> users = [];
        responseBody.forEach((item) {
          Map<String, dynamic> properties = item['properties'];
          String username = properties['username']?['value'] ?? '';
          String role = properties['role']?['value'] ?? '';
          String state = properties['state']?['value'] ?? '';
          String email = properties['email']?['value'] ?? '';
          String name = properties['name']?['value'] ?? '';
          String number = properties['number']?['value'] ?? '';
          String profile = properties['profile']?['value'] ?? '';
          String address = properties['address']?['value'] ?? '';
          String occupation = properties['occupation']?['value'] ?? '';
          String workplace = properties['workplace']?['value'] ?? '';
          String postCode = properties['postCode']?['value'] ?? '';
          String nif = properties['nif']?['value'] ?? '';
          String imagePath = properties['imagePath']?['value'] ?? '';
          users.add({
            'username': username,
            'role': role,
            'state': state,
            'email': email,
            'name': name,
            'number': number,
            'profile': profile,
            'address': address,
            'occupation': occupation,
            'workplace': workplace,
            'postCode': postCode,
            'nif': nif,
            'imagePath': imagePath,
          });
        });
        setState(() {
          _userList = users;
          print('User list: $_userList');
          _isLoading = false;
        });
      } else {
        print('Response body is null or empty.');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print('HTTP request failed with status code ${response.statusCode}');
    }
  }
}
