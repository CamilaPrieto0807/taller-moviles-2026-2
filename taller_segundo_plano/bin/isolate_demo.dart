import 'dart:async';
import 'dart:isolate';

/// Ajusta este valor para que cada cálculo tarde unos 3-5 segundos.
const int kIteraciones = 500000000;

/// Tarea CPU-bound: suma grande con muchas operaciones.
int sumaPesada(int n) {
  var total = 0;
  for (var i = 0; i < n; i++) {
    total += (i % 7) * (i % 13);
  }
  return total;
}

/// Punto de entrada del Isolate (función de nivel superior).
void entradaIsolate(List<Object> args) {
  final puerto = args[0] as SendPort;
  final n = args[1] as int;

  print('   [ISOLATE] iniciado, calculando...');
  final sw = Stopwatch()..start();
  final resultado = sumaPesada(n);
  sw.stop();
  print('   [ISOLATE] terminó en ${sw.elapsedMilliseconds} ms');

  puerto.send({'resultado': resultado, 'ms': sw.elapsedMilliseconds});
}

Future<void> main() async {
  print('=== DEMO ISOLATE (Taller 2 - María Camila Prieto Barbosa) ===');

  // "Latido" del hilo principal: simula la UI. Si se detiene, el hilo está bloqueado.
  var ticks = 0;
  final latido = Timer.periodic(const Duration(milliseconds: 500), (_) {
    ticks++;
    print('   [MAIN] latido #$ticks (el hilo principal está libre)');
  });

  // ---------- 1) En un Isolate ----------
  print('\n--- 1) Tarea pesada en un ISOLATE ---');
  final ticksInicioIsolate = ticks;
  final totalIsolate = Stopwatch()..start();
  final puerto = ReceivePort();

  print('[MAIN] Creando Isolate...');
  await Isolate.spawn<List<Object>>(entradaIsolate, [puerto.sendPort, kIteraciones]);
  print('[MAIN] Isolate creado. El hilo principal sigue libre');

  final msg = await puerto.first as Map;
  puerto.close();
  totalIsolate.stop();
  final latidosIsolate = ticks - ticksInicioIsolate;

  print('[MAIN] Resultado recibido: ${msg['resultado']}');
  print('[MAIN] Tiempo de cálculo (Isolate): ${msg['ms']} ms');
  print('[MAIN] Tiempo total con mensajes: ${totalIsolate.elapsedMilliseconds} ms');
  print('[MAIN] Latidos durante el Isolate: $latidosIsolate  -> UI NO bloqueada');

  // ---------- 2) En el hilo principal ----------
  await Future.delayed(const Duration(milliseconds: 1200));
  print('\n--- 2) La MISMA tarea en el HILO PRINCIPAL ---');
  final ticksInicioMain = ticks;
  print('[MAIN] Calculando en el hilo principal (los latidos se detienen)...');
  final sw = Stopwatch()..start();
  final resultadoMain = sumaPesada(kIteraciones);
  sw.stop();
  await Future.delayed(const Duration(milliseconds: 10));
  final latidosMain = ticks - ticksInicioMain;

  print('[MAIN] Resultado: $resultadoMain');
  print('[MAIN] Tiempo de cálculo (hilo principal): ${sw.elapsedMilliseconds} ms');
  print('[MAIN] Latidos durante el cálculo: $latidosMain  -> UI BLOQUEADA');

  latido.cancel();
  print('\n=== RESUMEN ===');
  print('Isolate: ${msg['ms']} ms, $latidosIsolate latidos (UI libre)');
  print('Hilo principal: ${sw.elapsedMilliseconds} ms, $latidosMain latidos (UI bloqueada)');
}
