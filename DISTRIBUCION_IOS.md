# Distribución de Aleja para iPhone

## Estado actual

- La app nativa y su extensión WidgetKit están en el repositorio [anhjs01/ios](https://github.com/anhjs01/ios).
- GitHub Actions compila el proyecto para el simulador de iOS y valida el calendario y la configuración del widget.
- **La app no está publicada en App Store y todavía no hay un archivo IPA firmado para instalar en un iPhone.**
- Un resultado verde de CI no equivale a una app publicada ni a una instalación en un dispositivo físico.

## Qué se necesita para probarla en un iPhone

1. Tener acceso a un Mac con una versión compatible de Xcode, propio o prestado, o configurar un servicio de compilación para iOS.
2. Abrir `Aleja.xcodeproj` en Xcode y seleccionar el target `Aleja`.
3. Configurar el equipo de desarrollo y la firma para el identificador `com.anhjs01.aleja`.
4. Habilitar el App Group `group.com.anhjs01.aleja` tanto para la app como para el widget, y confirmar que los entitlements estén habilitados para el equipo.
5. Conectar el iPhone, seleccionar el dispositivo en Xcode y ejecutar la app.
6. Probar en el dispositivo los recordatorios, el guardado de mensajes, los enlaces profundos y ambos widgets.

La compilación de simulador generada por CI no se puede instalar directamente en un iPhone físico. No se debe presentar ese artefacto como una descarga para iOS.

## Probar mediante TestFlight

Para distribuir una beta a un iPhone sin conectar el dispositivo a Xcode:

1. Contar con una membresía activa de Apple Developer Program.
2. Configurar firma, identificadores y App Group en Apple Developer.
3. Archivar la app para un dispositivo genérico iOS en Xcode y subir el archivo a App Store Connect.
4. Completar la información requerida para la beta y esperar el procesamiento de Apple.
5. Añadir a las personas que van a probarla y compartir la invitación de TestFlight.

La disponibilidad de la beta depende del procesamiento y de los requisitos de Apple. El repositorio por sí solo no crea la invitación.

## Publicación en App Store

1. Completar las pruebas en dispositivo real, incluidos los widgets y permisos.
2. Revisar los derechos de uso del contenido musical y cualquier requisito de privacidad.
3. Preparar los metadatos, capturas, clasificación por edades y la información de privacidad que corresponda.
4. Subir una versión firmada a App Store Connect y enviarla a revisión.
5. Publicarla solo después de que Apple la apruebe.

## Consideraciones pendientes antes de distribuir

- La música utiliza enlaces de YouTube. No se ha implementado un reproductor de audio nativo ni se garantiza reproducción en segundo plano.
- iOS decide cuándo actualizar los widgets; los horarios previstos no garantizan una actualización exacta a las 06:00, 12:00 o 18:00.
- El historial se guarda localmente en cada iPhone. No hay sincronización entre dispositivos implementada.
- Los recordatorios son notificaciones locales y requieren autorización del usuario.

## Enlaces útiles

- [Repositorio de la app](https://github.com/anhjs01/ios)
- [Compilaciones y validaciones automáticas](https://github.com/anhjs01/ios/actions)
- [Apple Developer Program](https://developer.apple.com/programs/)
- [App Store Connect](https://appstoreconnect.apple.com/)
- [TestFlight](https://testflight.apple.com/)
