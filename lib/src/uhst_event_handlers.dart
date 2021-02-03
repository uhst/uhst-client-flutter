library uhst;

import 'contracts/uhst_socket.dart';
import 'models/message.dart';

typedef void OpenHandler({required String data});
typedef void MessageHandler({required Message? message});
typedef void ErrorHandler({required Error error});
typedef void CloseHandler();
typedef void DiagnosticHandler({required String message});

typedef void HostReadyHandler();
typedef void HostConnectionHandler({required UhstSocket uhstSocket});
