# Mundialito - tareas de implementacion

## Alcance acordado
- [x] App Flutter sin registro, en espanol e ingles.
- [x] Enfoque principal: Mundial 2026.
- [x] Soporte para mundiales historicos desde selector de temporada.
- [x] Datos reales via WorldCup26 para 2026 detras de Flupibase Functions.
- [x] API-FOOTBALL queda como respaldo para mundiales historicos.
- [x] No exponer API key dentro del cliente Flutter.
- [x] Leer configuracion local desde `config/.env` para ejecutar con F5.
- [x] Sin data mockeada en la app.
- [x] Function Flupibase sin endpoints arbitrarios, con recursos permitidos.
- [x] Sin inventar eventos minuto a minuto si el proveedor no los entrega.
- [x] Cachear temporadas en memoria para evitar parpadeo al cambiar de ano.
- [x] Refrescar datos reales en segundo plano para comportamiento en vivo.
- [x] Home visual inspirado en la referencia: fondo oscuro oliva, acento lima, cards curvas, live badges, escudos y microanimaciones.
- [x] Splash animado con CustomPainter.
- [x] README y licencia MIT.
- [x] Sin ejecutar `pub get`, `flutter analyze`, tests, formatters, `npm install` ni deploys.

## Implementacion
- [x] Registrar dependencias y configuracion base.
- [x] Cargar `config/.env` como asset con prioridad secundaria a `--dart-define`.
- [x] Crear modelos de dominio para partidos, equipos, eventos y standings.
- [x] Crear cliente HTTP y repositorio sin fallback mock.
- [x] Crear Flupibase Function `mundialito-football`.
- [x] Crear controlador de estado y localizacion ES/EN.
- [x] Agregar refresco silencioso cada 30 segundos sin limpiar la UI.
- [x] Construir splash animado.
- [x] Construir homepage estilo referencia.
- [x] Construir detalle de partido con timeline real cuando el proveedor lo entrega.
- [x] Documentar setup de Flupibase y ejecucion Flutter.
- [x] Agregar licencia MIT.

## Validacion pendiente por el usuario
- [ ] Ejecutar `flutter pub get`.
- [ ] Ejecutar `npm.cmd --prefix functions install`.
- [ ] Configurar secret `API_FOOTBALL_KEY` en Flupibase si se quieren historicos.
- [ ] Desplegar Flupibase Function.
- [ ] Ejecutar app con F5 leyendo `config/.env`, o usar `--dart-define` si se quiere sobreescribir esos valores.
- [ ] Ejecutar `flutter analyze`.
- [ ] Ejecutar tests.
