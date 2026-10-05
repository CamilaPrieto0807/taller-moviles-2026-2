import 'dart:async';

import 'package:flutter/material.dart';

enum EstadoCrono { detenido, corriendo, pausado }

class CronometroPage extends StatefulWidget {
  const CronometroPage({super.key});

  @override
  State<CronometroPage> createState() => _CronometroPageState();
}

class _CronometroPageState extends State<CronometroPage> {
  final Stopwatch _sw = Stopwatch();
  Timer? _timer;
  EstadoCrono _estado = EstadoCrono.detenido;

  void _arrancar() {
    _sw.start();
    _timer?.cancel();
    // Refresca la pantalla cada 100 ms
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {});
    });
    setState(() => _estado = EstadoCrono.corriendo);
  }

  void _iniciar() {
    debugPrint('Cronómetro: INICIAR');
    _arrancar();
  }

  void _pausar() {
    debugPrint('Cronómetro: PAUSAR (timer cancelado)');
    _timer?.cancel(); // limpieza del recurso al pausar
    _timer = null;
    _sw.stop();
    setState(() => _estado = EstadoCrono.pausado);
  }

  void _reanudar() {
    debugPrint('Cronómetro: REANUDAR');
    _arrancar();
  }

  void _reiniciar() {
    debugPrint('Cronómetro: REINICIAR');
    _timer?.cancel();
    _timer = null;
    _sw.stop();
    _sw.reset();
    setState(() => _estado = EstadoCrono.detenido);
  }

  @override
  void dispose() {
    // Limpieza al salir de la vista
    _timer?.cancel();
    debugPrint('Cronómetro: vista cerrada, timer cancelado');
    super.dispose();
  }

  String _formato() {
    final ms = _sw.elapsedMilliseconds;
    final min = (ms ~/ 60000).toString().padLeft(2, '0');
    final seg = ((ms ~/ 1000) % 60).toString().padLeft(2, '0');
    final dec = ((ms % 1000) ~/ 100).toString();
    return '$min:$seg.$dec';
  }

  String get _textoEstado => switch (_estado) {
        EstadoCrono.detenido => 'Detenido',
        EstadoCrono.corriendo => 'Corriendo',
        EstadoCrono.pausado => 'Pausado',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cronómetro con Timer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formato(),
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 8),
            Text('Estado: $_textoEstado', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (_estado == EstadoCrono.detenido)
                  FilledButton.icon(
                    onPressed: _iniciar,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar'),
                  ),
                if (_estado == EstadoCrono.corriendo)
                  FilledButton.icon(
                    onPressed: _pausar,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pausar'),
                  ),
                if (_estado == EstadoCrono.pausado)
                  FilledButton.icon(
                    onPressed: _reanudar,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Reanudar'),
                  ),
                OutlinedButton.icon(
                  onPressed: _estado == EstadoCrono.detenido ? null : _reiniciar,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reiniciar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
