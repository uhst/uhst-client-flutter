import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uhst/uhst.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter UHST Example',
        theme:
            ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
        home: const MyHomePage(title: 'Flutter UHST Example'),
      );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    required this.title,
    Key? key,
  }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
  }
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> hostMessages = [];
  final List<String> clientMessages = [];
  UHST? uhst;
  UhstHost? host;
  UhstSocket? client;
  final TextEditingController _hostIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> initHost() async {
    initUHST();
    host?.disconnect();
    host = uhst?.host();
    host
      ?..onReady(handler: ({required hostId}) {
        setState(() {
          hostMessages.add('Host Ready! Using $hostId');
          print('host is ready!');
          _hostIdController.text = hostId;
        });
      })
      ..onException(handler: ({required dynamic exception}) {
        if (exception is RelayException) {
          hostMessages.add('disconneted! $exception');
        } else {
          hostMessages.add('exception received! $exception');
        }
        setState(() {});
      })
      ..onConnection(handler: ({required uhstSocket}) {
        uhstSocket
          ..onDiagnostic(handler: ({required message}) {
            setState(() {
              hostMessages.add(message);
            });
          })
          ..onMessage(handler: ({required message}) {
            setState(() {
              hostMessages
                  .add('Host received: $message from ${uhstSocket.remoteId}');
            });
            host?.broadcastString(message: message);
          })
          ..onOpen(handler: () {
            setState(() {
              hostMessages.add('Client ${uhstSocket.remoteId} connected');
            });
          })
          ..onClose(handler: () {
            hostMessages.add('Client ${uhstSocket.remoteId} disconected');
          });
      });
  }

  void initUHST() {
    uhst ??= UHST(
      debug: true,
      relayUrl: 'http://127.0.0.1:3000',
    );
  }

  Future<void> join() async {
    initUHST();
    client?.close();
    client = uhst?.join(hostId: _hostIdController.text);
    client
      ?..onException(handler: ({required dynamic exception}) {
        if (exception is InvalidHostId || exception is InvalidClientOrHostId) {
          clientMessages.add('Invalid hostId!');
        } else {
          clientMessages.add(exception.toString());
        }
        setState(() {});
      })
      ..onDiagnostic(handler: ({required message}) {
        setState(() {
          clientMessages.add(message);
        });
      })
      ..onOpen(handler: () {
        setState(() {
          clientMessages.add('Client connected to host: ${client?.remoteId}');
        });
      })
      ..onClose(handler: () {
        clientMessages.add('Connection to host ${client?.remoteId} dropped.');
      })
      ..onMessage(handler: ({required message}) {
        setState(() {
          clientMessages.add('Client received: $message');
        });
      });
  }

  TextEditingController hostTextFieldController = TextEditingController();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was
          // created by the App.build method, and use it to
          // set our appbar title.
          title: Text(widget.title),
        ),
        body: Row(
          children: [
            Flexible(
              flex: 2,
              child: Material(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Setup & checks',
                          ),
                        ),
                        const Divider(
                          height: 22,
                        ),
                        TextField(
                          decoration:
                              const InputDecoration(labelText: 'Host id'),
                          controller: _hostIdController,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextButton(
                            onPressed: initHost,
                            child: const Text('Start hosting')),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButton(
                          onPressed: () async => join(),
                          child: const Text('Click to join a host'),
                        ),
                        const Divider(
                          height: 22,
                          thickness: 1,
                        ),
                        const Center(
                          child: Text('Host chat'),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) =>
                                Text(hostMessages[index]),
                            itemCount: hostMessages.length,
                          ),
                        )
                      ],
                    ),
                  )),
            ),
            Flexible(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      const Text('Client chat'),
                      const Divider(
                        height: 22,
                      ),
                      TextField(
                        controller: hostTextFieldController,
                        decoration: InputDecoration(
                            suffix: IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: () {
                                  client?.sendString(
                                      message: hostTextFieldController.text);
                                })),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) =>
                              Text(clientMessages[index]),
                          itemCount: clientMessages.length,
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ),
      );
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(IterableProperty<String>('hostMessages', hostMessages))
      ..add(DiagnosticsProperty<UHST?>('uhst', uhst))
      ..add(DiagnosticsProperty<TextEditingController>(
          'hostTextFieldController', hostTextFieldController))
      ..add(DiagnosticsProperty<UhstSocket?>('client', client))
      ..add(IterableProperty<String>('clientMessages', clientMessages))
      ..add(DiagnosticsProperty<UhstHost?>('host', host));
  }
}
