import 'uhst_socket.dart';

/// Handler called when a socket opens.
typedef OpenHandler = void Function();

/// Handler called when a message is received.
typedef MessageHandler = void Function({required String message});

/// Handler called when an exception occurs.
typedef ExceptionHandler = void Function({required dynamic exception});

/// Handler called when a connection closes.
typedef CloseHandler = void Function({required String hostId});

/// Handler called for diagnostic messages.
typedef DiagnosticHandler = void Function({required String message});

/// Handler called when a host is ready.
typedef HostReadyHandler = void Function({required String hostId});

/// Handler called when a client connects to a host.
typedef HostConnectionHandler = void Function({required UhstSocket uhstSocket});
