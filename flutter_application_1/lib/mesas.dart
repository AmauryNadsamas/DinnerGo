import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'variables.dart';

class TableSelectionPage extends StatefulWidget {
  const TableSelectionPage({super.key});

  @override
  _TableSelectionPageState createState() => _TableSelectionPageState();
}

class _TableSelectionPageState extends State<TableSelectionPage> {
  List<Map<String, dynamic>> _tables = [];

  @override
  void initState() {
    super.initState();
    _fetchTableStates();
  }

  Future<void> _fetchTableStates() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.41:8888/restaurant/get_table_states.php'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _tables = List<Map<String, dynamic>>.from(data['tables']);
          });
        } else {
          _showSnackBar(data['message']);
        }
      } else {
        _showSnackBar('Error al obtener el estado de las mesas');
      }
    } catch (e) {
      _showSnackBar('Error de conexión: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showOccupiedMessage(BuildContext context, int tableId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mesa Ocupada'),
        content: Text(
          'La mesa $tableId ya está ocupada. ¿Deseas continuar o revisar su estado?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cerrar el diálogo
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Acción adicional para mesas ocupadas, si es necesario
              Navigator.pushNamed(context, '/mensaje');
              Globales.selectedTable = tableId;
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.redAccent,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4.0,
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.only(top: 15.0),
            child: Center(
              child: Text(
                'Seleccionar Mesa',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _tables.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: _tables.length,
                itemBuilder: (context, index) {
                  final table = _tables[index];
                  final isAvailable = table['estado'] == 'disponible';

                  return SlideInUp(
                    duration: Duration(milliseconds: 200 * (index + 1)),
                    child: GestureDetector(
                      onTap: () {
                        if (isAvailable) {
                          // Acción para mesas disponibles
                          Navigator.pushNamed(context, '/mensaje');
                          Globales.selectedTable = table['id'];
                        } else {
                          // Acción para mesas ocupadas
                          _showOccupiedMessage(context, table['id']);
                        }
                      },
                      child: Card(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        color: isAvailable
                            ? const Color.fromARGB(
                                255, 63, 63, 63) // Color para mesas disponibles
                            : Colors.redAccent, // Color para mesas ocupadas
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.table_bar,
                              size: 50.0,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              'Mesa ${table['id']}',
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
