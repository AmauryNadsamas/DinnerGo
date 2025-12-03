import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'variables.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  final List<Map<String, dynamic>> _cartItems = [];
  // ignore: unused_field
  final bool _showScrollIndicator = false;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    final int mesa = Globales.selectedTable; // Número de mesa seleccionada
    final url =
        Uri.parse('http://192.168.0.41:8888/restaurant/get_cart_items.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'numero_mesa': mesa}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _cartItems.addAll(List<Map<String, dynamic>>.from(data['data']));
          });
        } else {
          _showSnackBar(data['message']);
        }
      } else {
        _showSnackBar('Error al cargar los datos del carrito');
      }
    } catch (e) {
      _showSnackBar('Error de conexión: $e');
    }
  }

  Future<int?> _addToHistory(int numeroMesa, String usuario,
      List<Map<String, dynamic>> cartItems, double total) async {
    try {
      // Extraer solo los nombres de los platillos de los ítems
      final items = cartItems.map((item) => item['nombre_platillo']).join(', ');

      final response = await http.post(
        Uri.parse('http://192.168.0.41:8888/restaurant/add_to_history.php'),
        body: {
          'numeroMesa':
              numeroMesa.toString(), // Convierte el número de mesa a String
          'items': items,
          'total': total.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          print("Pedido agregado al historial con ID: ${data['id_pedido']}");
          return data['id_pedido']; // Devolver el ID del pedido registrado
        } else {
          print("Error al registrar en historial: ${data['message']}");
          return null;
        }
      } else {
        print("Error en respuesta al registrar en historial: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error en _addToHistory: $e");
      return null;
    }
  }

  Future<bool> _validatePassword(String password) async {
    final url =
        Uri.parse('http://192.168.0.41:8888/restaurant/validate_password.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valid']; // Respuesta { "valid": true/false }
      } else {
        _showSnackBar('Error en el servidor. Intenta nuevamente.');
        return false;
      }
    } catch (e) {
      _showSnackBar('Error de conexión: $e');
      return false;
    }
  }

  double _calculateTotal() {
    return _cartItems.fold(
      0,
      (sum, item) =>
          sum +
          (double.parse(item['precio'].toString()) *
              int.parse(item['cantidad'].toString())),
    );
  }

  void _confirmRemoveItem(int index) {
    final item = _cartItems[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Platillo'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${item['nombre_platillo']}" del pedido?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await _removeItemFromDatabase(
                Globales.selectedTable,
                int.parse(item['id'].toString()),
              );
              if (success) {
                setState(() {
                  _cartItems.removeAt(index);
                });
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(int index, int change) async {
    final item = _cartItems[index];
    final currentQuantity = int.parse(item['cantidad'].toString());
    final newQuantity = currentQuantity + change;

    if (newQuantity <= 0) {
      // Eliminar directamente sin mostrar confirmación
      final mesa = Globales.selectedTable;
      final success = await _removeItemFromDatabase(mesa, item['id']);
      if (success) {
        setState(() {
          _cartItems.removeAt(index); // Eliminar de la interfaz
        });
        _showSnackBar('Platillo eliminado exitosamente.');
      } else {
        _showSnackBar('Error al eliminar el platillo.');
      }
    } else {
      setState(() {
        item['cantidad'] = newQuantity; // Actualizar cantidad en la interfaz
      });
    }
  }

  void _showPasswordDialog() {
    final TextEditingController passwordController = TextEditingController();
    // ignore: unused_local_variable
    final int mesa = Globales.selectedTable; // Número de mesa seleccionada

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa tu contraseña para confirmar el pago:'),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contraseña',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar el diálogo al cancelar
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final password = passwordController.text;
              final isValid = await _validatePassword(password);

              if (isValid) {
                final numeroMesa = Globales.selectedTable;
                const usuario =
                    "Usuario Actual"; // Reemplazar por lógica para obtener el usuario

                // Llamar a la función para registrar el pedido en el historial
                final idPedido = await _addToHistory(
                    numeroMesa, usuario, _cartItems, _calculateTotal());

                if (idPedido != null) {
                  // Limpiar el carrito
                  setState(() {
                    _cartItems.clear();
                  });

                  // Cerrar el diálogo de confirmación antes de redirigir
                } else {
                  Navigator.pop(context);

                  // Mostrar el mensaje final de éxito y redirigir al login
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Orden Finalizada'),
                      content: const Text(
                          'La orden ha finalizado correctamente. Serás redirigido al login.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, '/loginpage');
                            _clearTable(numeroMesa);
                          },
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                }
              } else {
                _showSnackBar('Contraseña incorrecta.');
              }
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCartItems() async {
    final url =
        Uri.parse('http://192.168.0.41:8888/restaurant/update_cart_items.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'items': _cartItems.map((item) {
            return {
              'id': item['id'],
              'observaciones': item['observaciones'],
              'cantidad': item['cantidad'],
              'precio': item['precio'],
            };
          }).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _showSnackBar(data['message']);
        } else {
          _showSnackBar(data['message']);
        }
      } else {
        _showSnackBar('Error en el servidor. Código: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error de conexión: $e');
    }
  }

  // ignore: unused_element
  void _confirmPedidoWithUpdate() async {
    // Actualizar los ítems en la base de datos
    await _updateCartItems();

    // Confirmar el pedido después de actualizar
    _confirmPedido(context);
  }

  Future<bool> _clearTable(int numeroMesa) async {
    final url = Uri.parse(
        'http://192.168.0.41:8888/restaurant/clear_table.php'); // Ruta del PHP

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body:
            jsonEncode({'numero_mesa': numeroMesa}), // Enviar el número de mesa
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _showSnackBar(data['message']);
          return true;
        } else {
          _showSnackBar(data['message']);
          return false;
        }
      } else {
        _showSnackBar('Error en el servidor. Código: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _showSnackBar('Error de conexión: $e');
      return false;
    }
  }

  Future<bool> _removeItemFromDatabase(int mesa, int id) async {
    final url =
        Uri.parse('http://192.168.0.41:8888/restaurant/remove_cart_item.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'numero_mesa': mesa, 'id': id}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return true;
        } else {
          _showSnackBar(data['message']);
          return false;
        }
      } else {
        _showSnackBar('Error en el servidor. Intenta nuevamente.');
        return false;
      }
    } catch (e) {
      _showSnackBar('Error de conexión: $e');
      return false;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _confirmPedido(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Pedido'),
        content: const Text(
            'Entrega la tableta al mesero para finalizar el pedido. ¿Deseas continuar?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Seguir Ordenando'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _askForPassword(context);
            },
            child: const Text(
              'Continuar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _askForPassword(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar con Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu contraseña para confirmar el pedido:',
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Contraseña',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final password = passwordController.text;
              final isValid = await _validatePassword(password);

              if (isValid) {
                // Actualizar los ítems en la base de datos antes de confirmar el pedido
                await _updateCartItems();

                _showSnackBar('Pedido confirmado exitosamente');

                Navigator.pop(context);

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmación de orden'),
                    content: const Text(
                        'La orden ha sido confirmada correctamente. Serás redirigido al login.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/loginpage');
                        },
                        child: const Text('Aceptar'),
                      ),
                    ],
                  ),
                );
                setState(() {
                  _cartItems.clear(); // Limpia el carrito en la interfaz
                });
              } else {
                _showSnackBar('Contraseña incorrecta');
              }
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  void _showWarningForLargeQuantity(int index, int newQuantity) {
    final item = _cartItems[index];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Advertencia: Cantidad Alta'),
        content: Text(
          'Estás agregando una cantidad alta de "${item['nombre_platillo']}" ($newQuantity unidades). ¿Estás seguro de que deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                item['cantidad'] = newQuantity;
              });
              Navigator.pop(context);
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con diseño consistente
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.5, 1.7),
                radius: 1.5,
                colors: [
                  Colors.red.shade100,
                  Colors.red.shade300,
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
                left: 16.0, right: 16.0, top: 50, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pedido',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (_cartItems.isNotEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.only(right: 15, bottom: 8, top: 8, left: 15),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Platillo',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Observación',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Cantidad',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Precio',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
                Expanded(
                  child: _cartItems.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay platillos en el pedido',
                            style: TextStyle(fontSize: 20),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _cartItems.length,
                          itemBuilder: (context, index) {
                            final item = _cartItems[index];
                            // Controlador para cada campo de texto de observaciones
                            final TextEditingController
                                observacionesController = TextEditingController(
                                    text: item['observaciones']);

                            return Container(
                              color: Colors.black.withOpacity(0.3),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, bottom: 8.0, right: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.redAccent),
                                            onPressed: () =>
                                                _confirmRemoveItem(index),
                                          ),
                                          // Cambiado: usar Flexible/Expanded para que el texto se recorte correctamente
                                          Expanded(
                                            child: Text(
                                              item['nombre_platillo'],
                                              style:
                                                  const TextStyle(fontSize: 18),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              softWrap: false,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: TextField(
                                        controller: observacionesController,
                                        onChanged: (value) {
                                          // Actualizar la observación en _cartItems cuando el texto cambie
                                          _cartItems[index]['observaciones'] =
                                              value;
                                        },
                                        decoration: const InputDecoration(
                                          hintText: 'Observaciones',
                                          hintStyle: TextStyle(
                                              color: Colors
                                                  .grey), // Color del hint text
                                          filled: true, // Habilita el fondo
                                          fillColor:
                                              Colors.white, // Fondo blanco
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    20.0)), // Bordes redondeados
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    20.0)), // Bordes redondeados
                                            borderSide: BorderSide(
                                                color: Colors
                                                    .black), // Borde negro cuando no está enfocado
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    20.0)), // Bordes redondeados
                                            borderSide: BorderSide(
                                                color: Colors.red,
                                                width:
                                                    2.0), // Borde rojo cuando está enfocado
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 10.0,
                                            horizontal: 10.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.remove_circle,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _updateQuantity(index, -1),
                                          ),
                                          Text(
                                            '${item['cantidad']}',
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle,
                                                color: Colors.green),
                                            onPressed: () =>
                                                _updateQuantity(index, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '\$${(double.parse(item['precio'].toString()) * int.parse(item['cantidad'].toString())).toStringAsFixed(2)}',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 20),
                if (_cartItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                if (_cartItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _confirmPedido(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: const Text(
                            'Confirmar Pedido',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showPasswordDialog(); // Llama al cuadro de diálogo para la contraseña
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: const Text(
                            'Pagar Ahora',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
