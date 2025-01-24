import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart'; // Importar home.dart
import 'register.dart'; // Importar register.dart

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Definir rutas principales
      initialRoute: '/', // Ruta inicial
      routes: {
        '/': (context) => const MyHomePage(title: 'Flutter Demo Home Page'),
        '/home': (context) => HomePage(), // Ruta para HomePage
        '/register': (context) => RegisterPage(), // Ruta para RegisterPage
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _message = '';

  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse('https://kibbiapi.onrender.com/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _username,
          'password': _password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _message = 'Token: ${data['token']}';

        // Guardar el token en SharedPreferences
        _saveToken(data['token']);

        // Navegar a la página de inicio
        Navigator.pushReplacementNamed(context, '/home'); // Usar la ruta '/home'
      } else {
        setState(() {
          _message = 'Error: Credenciales incorrectas';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error de conexión: $e';
      });
    }
  }

  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token); // Guardar el token
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _login(); // Llamar a la función de login
                  }
                },
                child: const Text('Iniciar sesión'),
              ),
              const SizedBox(height: 20),
              Text(_message), // Mostrar el mensaje de error o éxito
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register'); // Usar la ruta '/register'
                },
                child: const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
