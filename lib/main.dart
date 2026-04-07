import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const SkullKingApp());

class SkullKingApp extends StatelessWidget {
  const SkullKingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skull King Scoreboard',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
      ),
      home: const PantallaPrincipal(),
    );
  }
}

// ─── Estado elevado al padre ───────────────────────────────────────────────
class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _rondaActual = 1;
  final List<Jugador> _jugadores = [
    Jugador(nombre: "Capitán"),
    Jugador(nombre: "Sirena"),
    Jugador(nombre: "Pirata 1"),
    Jugador(nombre: "Pirata 2"),
    Jugador(nombre: "Pirata 3"),
    Jugador(nombre: "Pirata 4"),
    Jugador(nombre: "Pirata 5"),
    Jugador(nombre: "Pirata 6"),
  ];

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        MesaCircularScreen(
          jugadores: _jugadores,
          rondaActual: _rondaActual,
          onChanged: () => setState(() {}),
          onRondaChanged: (r) => setState(() => _rondaActual = r),
        ),
        const ReglasScreen(),
      ],
    );
  }
}
// ───────────────────────────────────────────────────────────────────────────

class Jugador {
  String nombre;
  int puntos;
  Jugador({required this.nombre, this.puntos = 0});
}

class MesaCircularScreen extends StatefulWidget {
  final List<Jugador> jugadores;
  final int rondaActual;
  final VoidCallback onChanged;
  final ValueChanged<int> onRondaChanged;

  const MesaCircularScreen({
    super.key,
    required this.jugadores,
    required this.rondaActual,
    required this.onChanged,
    required this.onRondaChanged,
  });

  @override
  State<MesaCircularScreen> createState() => _MesaCircularScreenState();
}

class _MesaCircularScreenState extends State<MesaCircularScreen> {
  List<Jugador> get _jugadores => widget.jugadores;
  int get _rondaActual => widget.rondaActual;

  void _modificarPuntos(int index, int cantidad) {
    setState(() => _jugadores[index].puntos += cantidad);
    widget.onChanged();
  }

  void _addJugador() {
    if (_jugadores.length < 8) {
      setState(() => _jugadores.add(Jugador(nombre: "Nuevo Pirata")));
      widget.onChanged();
    }
  }

  void _cambiarRonda(int cantidad) {
    int nueva = (_rondaActual + cantidad).clamp(1, 10);
    widget.onRondaChanged(nueva);
  }

  void _confirmarReinicio() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ ¡Atención Pirata!'),
        content: const Text(
          '¿Estás seguro de que quieres poner todos los marcadores a cero y volver a la ronda 1?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              for (var j in _jugadores) {
                j.puntos = 0;
              }
              widget.onRondaChanged(1);
              widget.onChanged();
              Navigator.pop(context);
            },
            child: const Text('REINICIAR TODO'),
          ),
        ],
      ),
    );
  }

  void _renameJugador(int index) {
    TextEditingController controller = TextEditingController(
      text: _jugadores[index].nombre,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Pirata'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: "Nombre del pirata"),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                setState(() => _jugadores.removeAt(index));
                widget.onChanged();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              label: const Text(
                'ELIMINAR JUGADOR',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('VOLVER'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _jugadores[index].nombre = controller.text);
                widget.onChanged();
              }
              Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  void _mostrarGanador() {
    if (_jugadores.isEmpty) return;

    int maxPuntos = _jugadores.map((j) => j.puntos).reduce(math.max);
    List<Jugador> ganadores =
    _jugadores.where((j) => j.puntos == maxPuntos).toList();

    showGeneralDialog(
      context: context,
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, a1, a2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: a1, curve: Curves.elasticOut),
          child: AlertDialog(
            backgroundColor: const Color(0xFF1C252E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.amber, width: 2),
            ),
            title: Column(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 60),
                const SizedBox(height: 10),
                Text(
                  ganadores.length > 1 ? '¡EMPATE ÉPICO!' : '¡TENEMOS UN REY PIRATA!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ganadores.length > 1
                      ? 'El botín y la gloria se comparten entre:'
                      : 'El indiscutible ganador es:',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 15),
                ...ganadores.map((g) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '${g.nombre} (${g.puntos} pts)',
                    style: const TextStyle(
                        fontSize: 24,
                        color: Colors.amber,
                        fontWeight: FontWeight.bold),
                  ),
                )),
              ],
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('¡ARRR!',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 700),
    );
  }

  Offset _calcularPosicionSuperelipse(
      double angulo, double radioX, double radioY, double n) {
    double cosT = math.cos(angulo);
    double sinT = math.sin(angulo);

    double signCos = cosT >= 0 ? 1 : -1;
    double signSin = sinT >= 0 ? 1 : -1;

    double exponente = 2.0 / n;

    double x = radioX * math.pow(cosT.abs(), exponente) * signCos;
    double y = radioY * math.pow(sinT.abs(), exponente) * signSin;

    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚓ MESA SKULL KING'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _confirmarReinicio,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double centroX = constraints.maxWidth / 2;
          final double centroY = constraints.maxHeight / 2;

          final double radioX = (constraints.maxWidth / 2) - 85;
          final double radioY = (constraints.maxHeight / 2) - 100;
          const double factorFormaMesa = 3.0;

          return Stack(
            children: [
              Center(
                child: Container(
                  width: radioX * 2 + 100,
                  height: radioY * 2 + 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161C24),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.15),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 0.05,
                        child: Icon(
                          Icons.sailing,
                          size: math.min(radioX, radioY) * 1.2,
                          color: Colors.amber,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'RONDA',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: Colors.white54,
                                onPressed: _rondaActual > 1
                                    ? () => _cambiarRonda(-1)
                                    : null,
                              ),
                              Container(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '$_rondaActual',
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black54,
                                        blurRadius: 10,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                color: Colors.white54,
                                onPressed: _rondaActual < 10
                                    ? () => _cambiarRonda(1)
                                    : null,
                              ),
                            ],
                          ),
                          const Text(
                            'DE 10',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_rondaActual == 10) ...[
                            const SizedBox(height: 15),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                elevation: 8,
                              ),
                              icon:
                              const Icon(Icons.emoji_events, size: 20),
                              label: const Text('VER GANADOR',
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: _mostrarGanador,
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              ...List.generate(_jugadores.length, (i) {
                final double angulo =
                    (2 * math.pi * i) / _jugadores.length + (math.pi / 2);
                Offset pos = _calcularPosicionSuperelipse(
                    angulo, radioX, radioY, factorFormaMesa);

                final double x = centroX + pos.dx - 70;
                final double y = centroY + pos.dy - 60;

                return Positioned(
                  left: x,
                  top: y,
                  child: _buildTarjetaJugador(i),
                );
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addJugador,
        backgroundColor: Colors.amber,
        child: const Icon(Icons.person_add, color: Colors.black),
      ),
    );
  }

  Widget _buildTarjetaJugador(int index) {
    final jugador = _jugadores[index];
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF1C252E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.amber.withOpacity(0.8), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _renameJugador(index),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.white.withOpacity(0.05),
              child: Text(
                jugador.nombre.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '${jugador.puntos}',
              style:
              const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.remove_circle,
                  color: Colors.redAccent,
                  size: 28,
                ),
                onPressed: () => _modificarPuntos(index, -10),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.greenAccent,
                  size: 28,
                ),
                onPressed: () => _modificarPuntos(index, 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class ReglasScreen extends StatelessWidget {
  const ReglasScreen({super.key});

  Widget _buildReglaItem(String ganador, String accion, String perdedor,
      IconData iconoGanador, IconData iconoPerdedor, String bonus) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Icon(iconoGanador, color: Colors.greenAccent, size: 48),
                const SizedBox(height: 8),
                Text(ganador,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Text(accion.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.amber,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.greenAccent.withOpacity(0.5)),
                  ),
                  child: Text(bonus,
                      style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Icon(iconoPerdedor, color: Colors.redAccent, size: 48),
                const SizedBox(height: 8),
                Text(perdedor,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriaturaItem(
      String nombre, String descripcion, IconData icono, Color colorIcono) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: colorIcono, size: 50),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nombre,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorIcono)),
                const SizedBox(height: 5),
                Text(descripcion,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.white70, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📜 RECORDATORIO DE REGLAS'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const Icon(Icons.menu_book, size: 60, color: Colors.amber),
              const SizedBox(height: 20),

              const Text(
                'JERARQUÍA DE COMBATE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 30),
              _buildReglaItem('Pirata', 'vence a', 'Sirena',
                  Icons.sports_martial_arts, Icons.waves, '+20 PTS'),
              const Divider(color: Colors.white24, height: 30, thickness: 1),
              _buildReglaItem('Skull King', 'vence a', 'Pirata',
                  Icons.coronavirus, Icons.sports_martial_arts, '+30 PTS'),
              const Divider(color: Colors.white24, height: 30, thickness: 1),
              _buildReglaItem('Sirena', 'vence a', 'Skull King', Icons.waves,
                  Icons.coronavirus, '+40 PTS'),

              const SizedBox(height: 50),

              const Text(
                'CRIATURAS MARINAS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 30),
              _buildCriaturaItem(
                  'El Kraken',
                  'Destruye la baza por completo. Nadie gana la baza, ni siquiera el Skull King.',
                  Icons.dangerous,
                  Colors.redAccent),
              const Divider(color: Colors.white24, height: 20),
              _buildCriaturaItem(
                  'Ballena Blanca',
                  'Asusta a los personajes. Anula los poderes de todos los Piratas, Sirenas y del Skull King (cuentan como valor 0). Gana la carta con el número más alto.',
                  Icons.visibility_off,
                  Colors.cyanAccent),
              const SizedBox(height: 50),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border:
                  Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: const Text(
                  'Desliza hacia la izquierda para volver a la partida.',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}