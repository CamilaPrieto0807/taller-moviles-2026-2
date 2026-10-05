# Taller 2 – Asincronía, Timer e Isolate en Flutter

**Estudiante:** María Camila Prieto Barbosa · **Código:** 230222009
**Asignatura:** Móviles · **Institución:** UCEVA · **Docente:** Jairo Rodríguez
**Repositorio:** https://github.com/CamilaPrieto0807/taller-moviles-2026-2
**Rama del taller:** `feature/taller_segundo_plano`

## Objetivo

Aplicación Flutter que demuestra asincronía con `Future` y `async/await`, un cronómetro con `Timer` y una tarea pesada ejecutada en un `Isolate`, sin bloquear la interfaz.

## ¿Cuándo usar cada herramienta?

| Herramienta | Cuándo usarla | Ejemplo en este taller |
|---|---|---|
| `Future` | Representa un valor que estará disponible más adelante (operaciones de espera: red, base de datos, archivos). | `DatosService.consultarDatos()` |
| `async` / `await` | Esperar el resultado de un `Future` con código secuencial y legible, sin bloquear la UI. Permite usar `try/catch` para errores. | `_consultar()` en la pantalla Future |
| `Timer` | Ejecutar código una vez después de un tiempo (`Timer`) o de forma repetida (`Timer.periodic`). Hay que cancelarlo con `cancel()` para liberar recursos. | Cronómetro (refresco cada 100 ms) |
| `Isolate` | Tareas que consumen mucha CPU (cálculos, procesar datos grandes). Corre en otro hilo con memoria propia y se comunica por mensajes (`SendPort`/`ReceivePort`). | Suma de 500 millones de iteraciones |

**Diferencia clave:** `Future`/`async` y `Timer` no crean hilos nuevos: siguen en el hilo principal y solo sirven para *esperar* sin bloquear. Si el trabajo es *calcular* durante mucho tiempo, el hilo principal se congela y hay que usar un `Isolate`.

## Pantallas y flujos

```
Inicio (HomePage)
 ├── 1. Future / async / await
 ├── 2. Cronómetro con Timer
 └── 3. Tarea pesada con Isolate
```

### 1. Future / async / await
```
Botón "Consultar" → estado Cargando… → await Future.delayed(3 s)
        ├── sin falla → estado Éxito (muestra datos)
        └── con falla → estado Error (muestra mensaje)
```
Consola: `1. ANTES` → `2. DURANTE` → `3. DESPUÉS` → `4. FIN`.

### 2. Cronómetro
```
Detenido ──Iniciar──▶ Corriendo ──Pausar──▶ Pausado
   ▲                     │  ▲                  │
   │                     │  └────Reanudar──────┘
   └──────────Reiniciar──┴─────────────────────┘
```
`Timer.periodic` cada 100 ms; se cancela al pausar, reiniciar y en `dispose()`.

### 3. Isolate
```
Botón "Ejecutar en Isolate" → Isolate.spawn → cálculo en otro hilo
        → SendPort.send(resultado, ms) → ReceivePort → UI muestra tiempos
Botón "Hilo principal" → mismo cálculo en la UI → el indicador se congela
```

## Cómo ejecutar

```bash
flutter pub get
flutter run -d windows     # o un emulador/dispositivo Android
```
> `Isolate.spawn` no está soportado en Flutter Web (Chrome); ejecutar en Windows o Android.

## Estructura

```
lib/
 ├── main.dart              # Menú principal
 ├── future_page.dart       # Future / async / await
 ├── cronometro_page.dart   # Timer
 └── isolate_page.dart      # Isolate
```

## Flujo de trabajo Git (GitFlow)

`main` ← `dev` ← `feature/taller_segundo_plano` (PR hacia `dev` y luego `dev` → `main`).
