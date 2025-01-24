import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart'; // Asegúrate de importar el archivo main.dart

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _email = '';
  String _phone = '';
  String _message = '';

  Future<void> _register() async {
    final Map<String, dynamic> requestBody = {
      'username': _username,
      'password': _password,
      'correo': _email,
      'telefono': _phone,
      'direccion': 'Direccion aleatoria 123',
      'restaurantes': [],
    };

    // Imprimir el JSON que se enviará
    print('Enviando JSON: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        Uri.parse('https://kibbiapi.onrender.com/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // Registro exitoso
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => MyHomePage(
                  title: 'Flutter Demo Home Page')), // Redirigir a MyHomePage
        );
      } else {
        setState(() {
          _message = 'Error: No se pudo registrar. Verifica los datos.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error de conexión: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre de usuario';
                  }
                  return null;
                },
                onChanged: (value) {
                  _username = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu contraseña';
                  }
                  return null;
                },
                onChanged: (value) {
                  _password = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Por favor ingresa un correo válido';
                  }
                  return null;
                },
                onChanged: (value) {
                  _email = value;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Teléfono'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu número de teléfono';
                  }
                  return null;
                },
                onChanged: (value) {
                  _phone = value;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _register(); // Llamar a la función de registro
                    Navigator.pushNamed(context, '/home');
                  }
                },
                child: const Text('Registrar'),
              ),
              const SizedBox(height: 20),
              Text(_message), // Mostrar el mensaje de error o éxito
            ],
          ),
        ),
      ),
    );
  }
}
