import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:animate_do/animate_do.dart';
import 'cart.dart';
import 'variables.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.5, 1.7),
                radius: 1.5,
                colors: [
                  Color.fromRGBO(255, 205, 210, 1),
                  Color.fromRGBO(229, 115, 115, 1),
                ],
                stops: [0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 75,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(229, 115, 115, 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Mesa ${Globales.selectedTable}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          _getCurrentPage(),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.red.shade100,
        items: const <Widget>[
          Icon(Icons.menu, size: 30, color: Colors.black),
          Icon(Icons.shopping_cart, size: 30, color: Colors.black),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _getCurrentPage() {
    if (_currentIndex == 0) {
      return SlideInRight(child: const HomeContent());
    } else {
      return SlideInLeft(child: const Cart());
    }
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _selectedCategory = 'Entradas';
  final TextEditingController _searchController = TextEditingController();
  OverlayEntry? _overlayEntry;
  List<Map<String, dynamic>> _dishes = [];
  List<Map<String, dynamic>> _filteredDishes = [];

  @override
  void initState() {
    super.initState();
    _fetchDishes();
    _searchController.addListener(_filterDishes);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _addToOrder(String nombrePlatillo, double precio) async {
    final int mesa = Globales.selectedTable;

    final url =
        Uri.parse('http://192.168.0.41:8888/restaurant/add_to_order.php');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'numero_mesa': mesa, // Asegúrate de pasar numero_mesa
          'nombre_platillo': nombrePlatillo,
          'observaciones': '', // Campo vacío por ahora
          'cantidad': 1,
          'precio': precio,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success']) {
          _showSnackBar(data['message']);
          return true;
        } else if (data['message'] ==
            'El platillo ya está en el pedido, modifique la cantidad en el carrito.') {
          // Mensaje específico si el platillo ya existe
          _showSnackBar(data['message']);
          return false;
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

  Future<void> _fetchDishes() async {
    final url =
        Uri.parse('http://192.168.0.41:8888/restaurant/get_platillos.php');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _dishes = List<Map<String, dynamic>>.from(data['data']);
            _filteredDishes = _dishes
                .where((dish) => dish['category'] == _selectedCategory)
                .toList();
          });
        }
      }
    } catch (e) {
      _showSnackBar('Error al cargar los platillos: $e');
    }
  }

  void _filterDishes() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredDishes = _dishes
            .where((dish) => dish['category'] == _selectedCategory)
            .toList();
      } else {
        _filteredDishes = _dishes
            .where((dish) =>
                dish['title'].toLowerCase().contains(query) &&
                dish['category'] == _selectedCategory)
            .toList();
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  OverlayEntry _createOverlayEntry(
      String title, String ingredients, String imagePath, double price) {
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _hideOverlay,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            Center(
              child: ZoomIn(
                duration: const Duration(milliseconds: 700),
                child: Material(
                  color: Colors.transparent,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(245, 205, 210, 1),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imagePath,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              ingredients,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                final result = await _addToOrder(title, price);
                                if (result) {
                                  _showSnackBar(
                                      'Platillo agregado a la mesa ${Globales.selectedTable}');
                                } else {
                                  _showSnackBar(
                                      'El platillo ya está agregado. Ve al carrito para modificar la cantidad.');
                                }
                                _hideOverlay();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              child: const Text(
                                'Agregar a pedido',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -10,
                        left: -10,
                        child: GestureDetector(
                          onTap: _hideOverlay,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showOverlay(
      String title, String ingredients, String imagePath, double price) {
    _overlayEntry = _createOverlayEntry(title, ingredients, imagePath, price);
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const Text(
              'Bienvenido!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona los platillos para tu nuevo pedido',
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 205, 210, 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Busca un platillo',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryCard('Entradas', Icons.restaurant),
                _buildCategoryCard('Principal', Icons.fastfood),
                _buildCategoryCard('Postres', Icons.cake),
                _buildCategoryCard('Bebidas', Icons.local_drink),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              'Platillos populares',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 300,
              child: _filteredDishes.isEmpty
                  ? const Center(
                      child: Text('No se encontraron platillos'),
                    )
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: _filteredDishes.map((dish) {
                        return GestureDetector(
                          onTap: () {
                            _showOverlay(
                              dish['title'],
                              dish['ingredients'],
                              dish['image'],
                              double.parse(dish['price'].toString()),
                            );
                          },
                          child: _buildDishCard(
                            dish['title'],
                            dish['description'],
                            double.parse(dish['price'].toString()),
                            dish['image'],
                          ),
                        );
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 60),
            const Center(
              child: Text(
                'Presiona un platillo para ver más acerca de el.',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = title;
          _filterDishes();
        });
      },
      child: Container(
        width: 160,
        height: 160,
        padding: const EdgeInsets.only(top: 40, left: 45, right: 50),
        decoration: BoxDecoration(
          color: _selectedCategory == title
              ? Colors.red.shade300
              : const Color.fromRGBO(245, 205, 210, 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 50, color: Colors.black),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishCard(
      String title, String description, double price, String imagePath) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      height: 300,
      width: 200,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 205, 210, 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              image: DecorationImage(
                image: NetworkImage(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 22,
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 20,
                  child: Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
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
