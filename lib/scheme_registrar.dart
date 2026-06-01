// Punto de entrada con import condicional:
//   - En web (no hay dart:io) usa la versión "stub" que no hace nada.
//   - En el resto (móvil/escritorio) usa la versión con dart:io, que solo
//     actúa de verdad en Windows.
export 'scheme_registrar_stub.dart'
    if (dart.library.io) 'scheme_registrar_io.dart';
