# Aleja — app nativa para iOS

Aplicación personal para Aleja, desarrollada con SwiftUI y WidgetKit. Este repositorio es independiente de los proyectos web `mismatachos` y `alejamatachos`.

## Lo que ya está incorporado

- Proyecto de Xcode con una app SwiftUI y una extensión WidgetKit.
- Tres carticas por fecha, previstas para las 06:00, 12:00 y 18:00 (hora local del iPhone).
- Calendario para consultar días anteriores y futuros.
- Edición y almacenamiento local de los mensajes.
- Widget de inicio y widget rectangular de pantalla bloqueada, con fragmento de texto y enlace a la app.
- Catálogo musical original importado como datos: 360 canciones, en cuatro categorías.
- Calendario original importado como datos: 78 días consecutivos, del 16 de octubre de 2026 al 1 de enero de 2027.
- La música solo se abre cuando se pulsa un control; no hay reproducción automática.
- Recordatorios locales opcionales a las 06:00, 12:00 y 18:00, activados solo después de tocar el botón y conceder permiso.
- Flujo de compilación automatizado para intentar compilar en un runner de macOS con Xcode.

## Fuentes y contenido

Los datos del calendario y las canciones se adaptaron desde el proyecto web existente, sin modificarlo:

- `AlejaApp/Resources/calendario-original.json`
- `AlejaApp/Resources/catalogo-canciones.json`

El catálogo tiene 360 canciones distribuidas en amor (46), filosófica (210), hot (58) y ambiente (46). Cinco entradas de Shyheim aún no tienen ID de YouTube en la fuente original; se conservan sin inventar enlaces. No se detectaron IDs de YouTube duplicados en la importación.

El calendario fuente contiene 78 días, sin saltos de fecha, entre el 16 de octubre de 2026 y el 1 de enero de 2027. Las fechas fuera de ese intervalo muestran carticas editables de reserva hasta que se amplíe y revise el contenido.

## Música en iOS

Los enlaces originales son de YouTube, no archivos de audio directos. La app abre esos enlaces únicamente cuando la persona toca el botón. Esto conserva el comportamiento manual y evita intentar reproducir una página web con `AVPlayer`. La reproducción en segundo plano depende de YouTube y de la aplicación instalada. Todavía falta decidir e integrar una fuente de audio que permita controlar la reproducción nativamente sin prometer funciones que los enlaces actuales no ofrecen.

## Widgets y permisos

La app y el widget usan el grupo compartido `group.com.anhjs01.aleja`. Para que el intercambio funcione en un dispositivo real, habrá que habilitar ese App Group en la configuración de firma de Apple para ambos targets. Los widgets se actualizan según las políticas de WidgetKit; iOS no garantiza actualizaciones exactas a una hora determinada.

## Compilar y probar

El workflow `.github/workflows/ios-build.yml` intenta compilar el proyecto en un runner macOS. La compilación real y la instalación en un iPhone deben verificarse con Xcode. Para firmar e instalar en un dispositivo, también hay que configurar el equipo de desarrollo y los identificadores de firma.

## Próximos pasos

1. Revisar el resultado de la compilación automatizada y corregir cualquier error.
2. Ampliar el calendario más allá de los 78 días fuente sin duplicar ni inventar mensajes.
3. Revisar los enlaces musicales pendientes y decidir una solución de audio compatible con iOS.
4. Revisar el resultado de compilación de los últimos cambios de recordatorios y corregir lo que aparezca.
5. Probar el widget, los enlaces profundos, los permisos de notificaciones, el guardado y los enlaces musicales en un iPhone real.
