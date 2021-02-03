library uhst;

import '../uhst_event_handlers.dart';

abstract class UhstHostSocket {
  void onReady({required HostReadyHandler handler});
  void onConnection({required HostConnectionHandler handler});
  void onError({required ErrorHandler handler});
  void onDiagnostic({required DiagnosticHandler handler});

  void onceReady({required HostReadyHandler handler});
  void onceConnection({required HostConnectionHandler handler});
  void onceError({required ErrorHandler handler});
  void onceDiagnostic({required DiagnosticHandler handler});

  void offReady({required HostReadyHandler handler});
  void offConnection({required HostConnectionHandler handler});
  void offError({required ErrorHandler handler});
  void offDiagnostic({required DiagnosticHandler handler});

  void disconnect();
}
