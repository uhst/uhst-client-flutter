library uhst;

import 'uhst_socket.dart';

typedef void OpenHandler();
typedef void MessageHandler({required String message});
typedef void ErrorHandler({required dynamic error});
typedef void CloseHandler();
typedef void DiagnosticHandler({required String message});

typedef void HostReadyHandler({required String hostId});
typedef void HostConnectionHandler({required UhstSocket uhstSocket});
