import 'package:flutter/material.dart';

class ManagerPage extends StatelessWidget {
  final String restaurantId;

  const ManagerPage({Key? key, required this.restaurantId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Productos - Restaurante $restaurantId'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // Lógica para agregar producto
              },
              child: const Text('Agregar Producto'),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica para eliminar producto
              },
              child: const Text('Eliminar Producto'),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica para obtener productos
              },
              child: const Text('Obtener Productos'),
            ),
            ElevatedButton(
              onPressed: () {
                // Lógica para editar producto
              },
              child: const Text('Editar Producto'),
            ),
          ],
        ),
      ),
    );
  }
} 