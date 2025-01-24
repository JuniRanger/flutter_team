import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  int _page = 1; // Página actual
  int _limit = 5000; // Límite de productos por solicitud

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Obtener el token guardado

    if (token != null) {
      final response = await http.get(
        Uri.parse('https://kibbiapi.onrender.com/api/products?page=$_page&limit=$_limit'), // URL con paginación
        headers: {
          'Authorization': 'Bearer $token', // Agregar el token en los headers
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _products.addAll(data['products']); // Agregar nuevos productos a la lista existente
          _isLoading = false;
        });
      } else {
        // Manejar el error
        setState(() {
          _isLoading = false;
        });
        print('Error al obtener productos: ${response.statusCode}');
      }
    } else {
      // Manejar el caso en que no hay token
      setState(() {
        _isLoading = false;
      });
      print('No se encontró el token.');
    }
  }

  // Método para cargar más productos al llegar al final de la lista
  void _loadMoreProducts() {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _page++; // Aumentar la página
      });
      _fetchProducts(); // Llamar a la función para obtener más productos
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: _isLoading && _products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!scrollInfo.metrics.atEdge && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  _loadMoreProducts(); // Cargar más productos al llegar al final
                }
                return false;
              },
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  // Manejo de valores nulos
                  final productName = _products[index]['nombre'] ?? 'Nombre no disponible';
                  final productDescription = _products[index]['descripcion'] ?? 'Descripción no disponible';

                  return ListTile(
                    title: Text(productName),
                    subtitle: Text(productDescription),
                  );
                },
              ),
            ),
    );
  }
}