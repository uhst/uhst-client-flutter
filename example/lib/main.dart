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

  Future<void> startHosting() async {
    initUHST();
    host?.disconnect();
    host = uhst?.host();
    host
      ?..onReady(handler: ({required hostId}) {
        hostMessages.add('Host Ready! Using hostId $hostId');
        print('host is ready!');
        _hostIdController.text = hostId;
        setState(() {});
      })
      ..onException(handler: ({required dynamic exception}) {
        if (exception is RelayException) {
          hostMessages.add('disconneted! $exception');
        } else {
          hostMessages.add('exception received! $exception');
        }
        setState(() {});
      })
      ..onClose(handler: ({required hostId}) {
        hostMessages.add('Host $hostId disconnected');
        setState(() {});
      })
      ..onConnection(handler: ({required uhstSocket}) {
        uhstSocket
          ..onDiagnostic(handler: ({required message}) {
            hostMessages.add(message);
            setState(() {});
          })
          ..onMessage(handler: ({required message}) {
            hostMessages
                .add('Host received: $message from ${uhstSocket.remoteId}');
            setState(() {});
            host?.broadcastString(message: message);
          })
          ..onOpen(handler: () {
            hostMessages.add('Client ${uhstSocket.remoteId} connected');
            setState(() {});
          })
          ..onClose(handler: ({required hostId}) {
            hostMessages.add('Client $hostId disconected');
            setState(() {});
          });
      });
  }

  Future<void> stopHosting() async => host?.disconnect();
  void initUHST() {
    uhst ??= UHST(
      debug: true,
      // relayUrl: 'http://127.0.0.1:3000',
    );
  }

  Future<void> join() async {
    initUHST();
    client?.close();
    client = uhst?.join(hostId: _hostIdController.text);
    client
      ?..onException(handler: ({required dynamic exception}) {
        final text = '[EXCEPION]: ${exception.toString()}';
        if (exception is InvalidHostId || exception is InvalidClientOrHostId) {
          clientMessages.add('[EXCEPION]: Invalid hostId!');
        } else if (exception is HostDisconnected) {
          clientMessages.add(text);
        } else {
          clientMessages.add(text);
        }
        setState(() {});
      })
      ..onDiagnostic(handler: ({required message}) {
        clientMessages.add(message);
        setState(() {});
      })
      ..onOpen(handler: () {
        clientMessages.add('Client connected to host: ${client?.remoteId}');
        setState(() {});
      })
      ..onClose(handler: ({required hostId}) {
        clientMessages.add('Connection to host $hostId dropped.');
        setState(() {});
      })
      ..onMessage(handler: ({required message}) {
        clientMessages.add('Client received: $message');
        setState(() {});
      });
  }

  Future<void> diconnect() async => client?.close();
  @override
  void dispose() {
    client?.dispose();
    host?.dispose();
    super.dispose();
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
                        child: Text('Host'),
                      ),
                      const Divider(height: 22),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Host id'),
                        controller: _hostIdController,
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        children: [
                          const Text('Host actions:'),
                          ...[
                            TextButton(
                              onPressed: startHosting,
                              child: const Text('Start hosting'),
                            ),
                            TextButton(
                              onPressed: stopHosting,
                              child: const Text('Finish hosting'),
                            ),
                            TextButton(
                              onPressed: () {
                                hostMessages.clear();
                                setState(() {});
                              },
                              child: const Text('Clear host messages'),
                            ),
                          ].map(
                            (w) => Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: w,
                            ),
                          )
                        ],
                      ),
                      const Divider(
                        thickness: 1,
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text('Host chat & debug messages'),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, index) =>
                              Text(hostMessages[index]),
                          itemCount: hostMessages.length,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: Text('Client')),
                    const Divider(height: 22),
                    Wrap(
                      children: [
                        const Text('Client actions:'),
                        ...[
                          TextButton(
                            onPressed: join,
                            child: const Text('Join a host'),
                          ),
                          TextButton(
                            onPressed: diconnect,
                            child: const Text('Leave a host'),
                          ),
                          TextButton(
                            onPressed: () {
                              clientMessages.clear();
                              setState(() {});
                            },
                            child: const Text('Clear client messages'),
                          ),
                        ].map(
                          (w) => Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: w,
                          ),
                        )
                      ],
                    ),
                    const Divider(height: 22),
                    TextField(
                      controller: hostTextFieldController,
                      decoration: InputDecoration(
                        labelText: 'Client messsage',
                        suffix: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            if (client == null) {
                              clientMessages.add(
                                'No client initialized! '
                                'Start hosting and join a host first',
                              );
                            }

                            client?.sendString(
                                message: hostTextFieldController.text);
                            hostTextFieldController.clear();
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(child: Text('Client chat and debug messages')),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) =>
                            Text(clientMessages[index]),
                        itemCount: clientMessages.length,
                      ),
                    )
                  ],
                ),
              ),
            )
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
