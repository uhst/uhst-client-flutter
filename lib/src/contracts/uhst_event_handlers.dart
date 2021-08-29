part of uhst_contracts;

typedef OpenHandler = void Function();
typedef MessageHandler = void Function({required String message});
typedef ExceptionHandler = void Function({required dynamic exception});
typedef CloseHandler = void Function({required String hostId});
typedef DiagnosticHandler = void Function({required String message});

typedef HostReadyHandler = void Function({required String hostId});
typedef HostConnectionHandler = void Function({required UhstSocket uhstSocket});
