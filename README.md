# Aleja — app nativa para iOS

Aplicación personal para Aleja, desarrollada con SwiftUI y WidgetKit. Este repositorio es independiente de los proyectos web `mismatachos` y `alejamatachos`.

## Objetivos

- Tres carticas diarias, previstas para las 06:00, 12:00 y 18:00 (hora local del iPhone).
- Calendario para consultar días anteriores y futuros.
- Widgets de pantalla de inicio y pantalla bloqueada; el widget muestra un fragmento y abre la app para leer la cartica completa.
- Música con reproducción exclusivamente manual: nunca iniciar audio automáticamente.
- Contenido e historial locales en cada iPhone, sin sincronización entre dispositivos por defecto.
- Interfaz en español, con una identidad visual azul cielo y un estilo artístico/urbano.

## Estado inicial

Repositorio recién creado. La estructura de código se añadirá por etapas y se verificará antes de darla por terminada. El código fuente por sí solo no equivale a una app instalada ni a una compilación verificada.

## Requisitos para compilar

Se necesita macOS con una versión compatible de Xcode para crear/abrir el proyecto, configurar la firma, compilar y probar en un iPhone. El desarrollo de la lógica y la revisión del código pueden avanzar desde otros sistemas, pero la compilación y firma de iOS requieren Xcode.

## Decisiones técnicas

- SwiftUI para la aplicación.
- WidgetKit para widgets.
- Almacenamiento local inicialmente.
- La reproducción musical se implementará con APIs nativas compatibles con iOS; no se trasladará el reproductor basado en iframe de la web.
- Las notificaciones locales, si se usan para recordar las carticas, requerirán permiso explícito del usuario.

## Próximos pasos

1. Añadir modelos y almacenamiento local.
2. Crear la vista principal, el calendario y el detalle de cada cartica.
3. Añadir la extensión WidgetKit y el enlace profundo a cada día.
4. Integrar reproducción manual y revisar derechos/disponibilidad de las fuentes musicales.
5. Abrir en Xcode, compilar, probar y corregir en dispositivo real.