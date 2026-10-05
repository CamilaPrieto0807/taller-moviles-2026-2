import 'package:flutter/material.dart';

enum EstadoCarga { inicial, cargando, exito, error }

/// Servicio simulado: "consulta" datos con un retraso de 3 segundos.
class DatosService {
  Future<String> consultarDatos({bool fallar = false}) async {
    debugPrint('   [Servicio] Consultando datos (simulado, 3 s)...');
    await Future.delayed(const Duration(seconds: 3));
    if (fallar) {
      throw Exception('No se pudo conectar con el servidor');
    }
    debugPrint('   [Servicio] Datos listos');
    return 'Evento: Festival Sonoro 2026\n'
        'Lugar: Teatro Aurora · Tuluá\n'
        'Cupos disponibles: 120';
  }
}

class FuturePage extends StatefulWidget {
  const FuturePage({super.key});

  @override
  State<FuturePage> createState() => _FuturePageState();
}

class _FuturePageState extends State<FuturePage> {
  final _servicio = DatosService();
  EstadoCarga _estado = EstadoCarga.inicial;
  String _mensaje = 'Presiona un botón para consultar los datos.';
  int _toques = 0; // Prueba de que la UI no se bloquea mientras carga

  Future<void> _consultar({required bool fallar}) async {
    debugPrint('1. ANTES: se va a llamar al servicio');
    setState(() => _estado = EstadoCarga.cargando);

    try {
      final futuro = _servicio.consultarDatos(fallar: fallar);
      debugPrint('2. DURANTE: el Future está pendiente y la UI sigue activa');

      final resultado = await futuro; // espera sin bloquear la UI
      debugPrint('3. DESPUÉS: llegó el resultado -> ÉXITO');

      if (!mounted) return;
      setState(() {
        _estado = EstadoCarga.exito;
        _mensaje = resultado;
      });
    } catch (e) {
      debugPrint('3. DESPUÉS: ocurrió un error -> $e');
      if (!mounted) return;
      setState(() {
        _estado = EstadoCarga.error;
        _mensaje = e.toString().replaceFirst('Exception: ', '');
      });
    }
    debugPrint('4. FIN del método _consultar');
  }

  @override
  Widget build(BuildContext context) {
    final cargando = _estado == EstadoCarga.cargando;

    final (icono, titulo, color) = switch (_estado) {
      EstadoCarga.inicial => (Icons.info_outline, 'Listo para consultar', Colors.blueGrey),
      EstadoCarga.cargando => (Icons.hourglass_top, 'Cargando…', Colors.orange),
      EstadoCarga.exito => (Icons.check_circle, 'Éxito', Colors.green),
      EstadoCarga.error => (Icons.error, 'Error', Colors.red),
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Future / async / await')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (cargando)
                      const CircularProgressIndicator()
                    else
                      Icon(icono, size: 48, color: color),
                    const SizedBox(height: 12),
                    Text(titulo,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: color)),
                    const SizedBox(height: 8),
                    Text(cargando ? 'Esperando respuesta del servicio…' : _mensaje,
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: cargando ? null : () => _consultar(fallar: false),
              icon: const Icon(Icons.cloud_download),
              label: const Text('Consultar datos (éxito)'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: cargando ? null : () => _consultar(fallar: true),
              icon: const Icon(Icons.bug_report),
              label: const Text('Consultar datos (forzar error)'),
            ),
            const Divider(height: 32),
            const Text('La UI sigue respondiendo mientras carga:'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => setState(() => _toques++),
              child: Text('Toques: $_toques'),
            ),
          ],
        ),
      ),
    );
  }
}
