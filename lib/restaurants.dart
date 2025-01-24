import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'manager.dart'; // Asegúrate de importar el archivo manager.dart

class RestaurantsPage extends StatefulWidget {
  @override
  _RestaurantsPageState createState() => _RestaurantsPageState();
}

class _RestaurantsPageState extends State<RestaurantsPage> {
  List<dynamic> _restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  Future<void> _fetchRestaurants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username'); // Obtener el nombre de usuario guardado

    if (username != null) {
      final response = await http.get(
        Uri.parse('https://kibbiapi.onrender.com/api/users?page=1&limit=50000'), // URL de la API
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Filtrar los usuarios por el nombre de usuario
        final user = data['users'].firstWhere((user) => user['username'] == username, orElse: () => null);
        
        if (user != null) {
          // Obtener los restaurantes del usuario
          setState(() {
            _restaurants = user['restaurantes']; // Asumiendo que 'restaurantes' es una lista de objetos
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
            _restaurants = []; // No hay restaurantes si no se encuentra el usuario
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Error al obtener usuarios: ${response.statusCode}');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print('No se encontró el nombre de usuario.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurantes'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = _restaurants[index]; // Accede correctamente usando el índice
                return ListTile(
                  title: Text(restaurant['nombre'] ?? 'Nombre no disponible'), // Mostrar el nombre del restaurante
                  onTap: () {
                    // Navegar a manager.dart al seleccionar un restaurante
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManagerPage(restaurantId: restaurant['_id'])),
                    );
                  },
                );
              },
            ),
    );
  }
} 