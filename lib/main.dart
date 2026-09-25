import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taller 1 - Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variable de estado que controla el título de la AppBar
  String _titulo = "Hola, Flutter";

  // Método que cambia el estado usando setState()
  void _cambiarTitulo() {
    setState(() {
      if (_titulo == "Hola, Flutter") {
        _titulo = "¡Título cambiado!";
      } else {
        _titulo = "Hola, Flutter";
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Título actualizado"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titulo),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- Nombre del estudiante dentro de un Container ----------
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo, width: 1.5),
              ),
              child: const Text(
                "María Camila Prieto Barbosa",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------- Row con Image.network() e Image.asset() ----------
            const Text(
              "Imágenes (network y asset)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Image.network(
                      'https://picsum.photos/150',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const SizedBox(
                          width: 140,
                          height: 140,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 60),
                    ),
                    const SizedBox(height: 6),
                    const Text("Image.network()"),
                  ],
                ),
                Column(
                  children: [
                    Image.asset(
                      'assets/images/foto.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 60),
                    ),
                    const SizedBox(height: 6),
                    const Text("Image.asset()"),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ---------- Botón que dispara setState() ----------
            ElevatedButton.icon(
              onPressed: _cambiarTitulo,
              icon: const Icon(Icons.refresh),
              label: const Text("Cambiar título"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            const SizedBox(height: 28),

            // ---------- Widget adicional 1: ListView ----------
            const Text(
              "Mis tareas del taller",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: const [
                    ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text("Crear StatefulWidget"),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text("Usar setState()"),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text("Agregar imágenes"),
                    ),
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.pending, color: Colors.orange),
                      title: Text("Subir a GitHub"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ---------- Widget adicional 2: Stack ----------
            const Text(
              "Evento destacado",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://picsum.photos/400/180',
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: const Text(
                    "Taller 1 - Flutter + Widgets + Git Flow",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}