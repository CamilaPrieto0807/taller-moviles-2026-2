import 'package:flutter/material.dart';

import 'cronometro_page.dart';
import 'future_page.dart';
import 'isolate_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taller 2 - Segundo plano',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _abrir(BuildContext context, Widget pagina) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => pagina));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Taller 2 - Segundo plano')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'María Camila Prieto Barbosa · 230222009',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('1. Future / async / await'),
              subtitle: const Text('Consulta simulada con Future.delayed'),
              onTap: () => _abrir(context, const FuturePage()),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('2. Cronómetro con Timer'),
              subtitle: const Text('Iniciar / Pausar / Reanudar / Reiniciar'),
              onTap: () => _abrir(context, const CronometroPage()),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.memory),
              title: const Text('3. Tarea pesada con Isolate'),
              subtitle: const Text('Hilo principal vs Isolate.spawn'),
              onTap: () => _abrir(context, const IsolatePage()),
            ),
          ),
        ],
      ),
    );
  }
}
