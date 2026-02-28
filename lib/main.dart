import 'package:flutter/material.dart';

void main() => runApp(const SkullKingApp());

class SkullKingApp extends StatelessWidget {
  const SkullKingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skull King Score',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
        // Configuración de la fuente por defecto para que sea más legible en tablet
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.amber,
          ),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 18, color: Colors.white70),
        ),
      ),
      home: const MarcadorScreen(),
    );
  }
}

class MarcadorScreen extends StatefulWidget {
  const MarcadorScreen({super.key});

  @override
  State<MarcadorScreen> createState() => _MarcadorScreenState();
}

class _MarcadorScreenState extends State<MarcadorScreen> {
  // Lista de objetos Jugador para mayor flexibilidad
  final List<Jugador> _jugadores = [
    Jugador(nombre: "Capitán Morgan"),
    Jugador(nombre: "Sirena"),
  ];

  void _modificarPuntos(int index, int cantidad) {
    setState(() {
      _jugadores[index].puntos += cantidad;
    });
  }

  void _addJugador() {
    setState(() {
      _jugadores.add(Jugador(nombre: "Pirata ${_jugadores.length + 1}"));
    });
  }

  void _renameJugador(int index) {
    String nuevoNombre = _jugadores[index].nombre;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renombrar Pirata'),
        content: TextField(
          autofocus: true,
          controller: TextEditingController(text: _jugadores[index].nombre),
          onChanged: (value) => nuevoNombre = value,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _jugadores[index].nombre = nuevoNombre);
              Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF12181F), // Fondo azul marino muy oscuro
      appBar: AppBar(
        title: const Text('⚓ SKULL KING MARCADOR'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          color: Colors.amber,
          letterSpacing: 1.2,
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _jugadores.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final jugador = _jugadores[index];
          return Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.amber, width: 0.5),
            ),
            color: const Color(
              0xFF1C252E,
            ), // Un tono más claro para el fondo de la card
            child: InkWell(
              // Hace que toda la card sea táctil
              onLongPress: () => _renameJugador(
                index,
              ), // Opción de renombrar con pulsación larga
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: IntrinsicHeight(
                  // Ajusta la altura de los elementos internos
                  child: Row(
                    children: [
                      // Nombre del Jugador y Puntuación
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.grey[600],
                                ), // Pista visual de editable
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    jugador.nombre.toUpperCase(),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow
                                        .ellipsis, // Para nombres muy largos
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              '${jugador.puntos}',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontSize: 40,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Controles de Puntuación
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle,
                              size: 40,
                              color: Colors.green,
                            ),
                            onPressed: () => _modificarPuntos(index, 10),
                          ),
                          const SizedBox(height: 12),
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              size: 40,
                              color: Colors.red,
                            ),
                            onPressed: () => _modificarPuntos(index, -10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addJugador,
        backgroundColor: Colors.amber,
        child: const Icon(Icons.person_add, size: 30, color: Colors.black),
      ),
    );
  }
}

// Clase auxiliar para gestionar los datos de cada jugador
class Jugador {
  String nombre;
  int puntos;

  Jugador({required this.nombre, this.puntos = 0});
}
