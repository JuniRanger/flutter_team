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
  bool _isFetchingMore = false; // Para controlar la carga de más productos
  int _page = 1; // Página actual
  int _limit = 20; // Límite de productos por solicitud
  String? _message; // Para almacenar mensajes de error

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Obtener el token guardado

    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse(
              'https://kibbiapi.onrender.com/api/products?page=$_page&limit=$_limit'), // URL con paginación
          headers: {
            'Authorization': 'Bearer $token', // Agregar el token en los headers
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _products.addAll(data[
                'products']); // Agregar nuevos productos a la lista existente
            _isLoading = false;
            _isFetchingMore = false; // Restablecer el estado de carga
          });
        } else {
          // Manejar el error
          setState(() {
            _isLoading = false;
            _isFetchingMore = false; // Restablecer el estado de carga
          });
          print('Error al obtener productos: ${response.statusCode}');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _isFetchingMore = false; // Restablecer el estado de carga
          _message = 'Error de conexión: $e'; // Mostrar el error en la interfaz
        });
        print('Error de conexión: $e'); // Imprimir el error en la consola
      }
    } else {
      // Manejar el caso en que no hay token
      setState(() {
        _isLoading = false;
        _isFetchingMore = false; // Restablecer el estado de carga
      });
      print('No se encontró el token.');
    }
  }

  // Método para cargar más productos al llegar al final de la lista
  void _loadMoreProducts() {
    if (!_isLoading && !_isFetchingMore) {
      setState(() {
        _isFetchingMore = true; // Indicar que se está cargando más
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
                if (!scrollInfo.metrics.atEdge &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  _loadMoreProducts(); // Cargar más productos al llegar al final
                }
                return false;
              },
              child: ListView.builder(
                itemCount: _products.length +
                    (_isFetchingMore
                        ? 1
                        : 0), // Agregar un indicador de carga si se está cargando más
                itemBuilder: (context, index) {
                  if (index == _products.length) {
                    return Center(
                        child:
                            CircularProgressIndicator()); // Indicador de carga
                  }
                  // Manejo de valores nulos
                  final productName =
                      _products[index]['nombre'] ?? 'Nombre no disponible';
                  final productDescription = _products[index]['descripcion'] ??
                      'Descripción no disponible';
                  final productPrice = _products[index]['precio']?.toString() ??
                      'Precio no disponible'; // Obtener el precio

                  return ListTile(
                    title: Text(productName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(productDescription),
                        Text('Precio: \$${productPrice}'), // Mostrar el precio
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(
              context, '/'); // Asegúrate de que esta ruta esté registrada
        },
        child: Icon(Icons.home),
        tooltip: 'Volver al Main',
      ),
    );
  }
}

