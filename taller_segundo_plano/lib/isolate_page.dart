import 'dart:isolate';

import 'package:flutter/material.dart';

/// Cantidad de iteraciones. Ajusta este valor para que el cálculo tarde
/// unos 3-5 segundos en tu equipo (más iteraciones = más tiempo).
const int kIteraciones = 500000000;

/// Tarea CPU-bound: suma grande con muchas operaciones.
int sumaPesada(int n) {
  var total = 0;
  for (var i = 0; i < n; i++) {
    total += (i % 7) * (i % 13);
  }
  return total;
}

/// Punto de entrada del Isolate (debe ser función de nivel superior).
void _entradaIsolate(List<Object> args) {
  final puerto = args[0] as SendPort;
  final n = args[1] as int;

  debugPrint('   [ISOLATE] iniciado, calculando...');
  final sw = Stopwatch()..start();
  final resultado = sumaPesada(n);
  sw.stop();
  debugPrint('   [ISOLATE] terminó en ${sw.elapsedMilliseconds} ms');

  puerto.send({'resultado': resultado, 'ms': sw.elapsedMilliseconds});
}

class IsolatePage extends StatefulWidget {
  const IsolatePage({super.key});

  @override
  State<IsolatePage> createState() => _IsolatePageState();
}

class _IsolatePageState extends State<IsolatePage> {
  bool _calculando = false;
  String _estado = 'Sin ejecutar';
  String? _resultadoIsolate;
  String? _resultadoMain;
  int _toques = 0;

  Future<void> _enIsolate() async {
    setState(() {
      _calculando = true;
      _estado = 'Calculando en Isolate… (la UI sigue libre)';
    });
    final total = Stopwatch()..start();
    final puerto = ReceivePort();

    try {
      debugPrint('[MAIN] Creando Isolate...');
      await Isolate.spawn<List<Object>>(
        _entradaIsolate,
        [puerto.sendPort, kIteraciones],
      );
      debugPrint('[MAIN] Isolate creado. La UI sigue respondiendo');

      final msg = await puerto.first as Map;
      total.stop();
      puerto.close();
      debugPrint('[MAIN] Resultado recibido: ${msg['resultado']} '
          '(cálculo ${msg['ms']} ms, total ${total.elapsedMilliseconds} ms)');

      if (!mounted) return;
      setState(() {
        _calculando = false;
        _estado = 'Isolate terminado';
        _resultadoIsolate = 'Resultado: ${msg['resultado']}\n'
            'Tiempo de cálculo: ${msg['ms']} ms\n'
            'Tiempo total (con mensajes): ${total.elapsedMilliseconds} ms';
      });
    } catch (e) {
      puerto.close();
      debugPrint('[MAIN] Error con Isolate: $e');
      if (!mounted) return;
      setState(() {
        _calculando = false;
        _estado = 'Error: $e';
      });
    }
  }

  Future<void> _enHiloPrincipal() async {
    setState(() {
      _calculando = true;
      _estado = 'Calculando en el hilo principal… (UI bloqueada)';
    });
    // Da tiempo a que Flutter pinte el mensaje antes de bloquear
    await Future.delayed(const Duration(milliseconds: 150));

    debugPrint('[MAIN] Calculando en el hilo principal: UI congelada');
    final sw = Stopwatch()..start();
    final resultado = sumaPesada(kIteraciones);
    sw.stop();
    debugPrint('[MAIN] Hilo principal terminó en ${sw.elapsedMilliseconds} ms');

    if (!mounted) return;
    setState(() {
      _calculando = false;
      _estado = 'Hilo principal terminado';
      _resultadoMain = 'Resultado: $resultado\n'
          'Tiempo de cálculo: ${sw.elapsedMilliseconds} ms';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarea pesada con Isolate')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: _calculando
                ? const CircularProgressIndicator()
                : const Icon(Icons.check_circle_outline, size: 40),
          ),
          const SizedBox(height: 8),
          const Text(
            'Si el indicador de carga se detiene, la UI está bloqueada.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text('Estado: $_estado',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _calculando ? null : _enIsolate,
            icon: const Icon(Icons.memory),
            label: const Text('Ejecutar en Isolate'),
          ),
          if (_resultadoIsolate != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_resultadoIsolate!),
              ),
            ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: _calculando ? null : _enHiloPrincipal,
            icon: const Icon(Icons.warning_amber),
            label: const Text('Ejecutar en hilo principal (bloquea)'),
          ),
          if (_resultadoMain != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_resultadoMain!),
              ),
            ),
          const Divider(height: 32),
          const Text('Prueba de UI libre: toca el botón mientras calcula.'),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => setState(() => _toques++),
            child: Text('Toques: $_toques'),
          ),
        ],
      ),
    );
  }
}
