library UHST;

import 'contracts/uhst_socket.dart';

typedef void OpenHandler({required String data});
typedef void MessageHandler({required String data});
typedef void ErrorHandler({required Error error});
typedef void CloseHandler();
typedef void DiagnosticHandler({required String message});

typedef void HostReadyHandler();
typedef void HostConnectionHandler({required UhstSocket uhstSocket});
