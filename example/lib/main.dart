import 'package:flutter/material.dart';
import 'package:uhst/uhst.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

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
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> hostMessages = [];
  final List<String> clientMessages = [];
  late Uhst uhst;
  UhstHost? host;
  UhstSocket? client;
  final TextEditingController _textController =
      TextEditingController(text: 'http://localhost:3000');
  @override
  void initState() {
    super.initState();
  }

  void initHost() async {
    uhst = Uhst(
        debug: true,
        apiUrl: _textController.text.isEmpty
            ? 'http://localhost:3000'
            : _textController.text,
        socketProvider: RelaySocketProvider());
    host = await uhst.host(hostId: 'testHost');

    print(host);
    host?.onReady(handler: () {
      hostMessages.add('Host Ready!');
      print('host is ready!');
    });
    host?.onError(handler: ({required Error error}) {
      print('error received! $error');
      if (error is HostIdAlreadyInUse) {
        // this is expected if you refresh the page
        // connection is still alive on the meeting point
        // just need to wait
        // TODO: why is it needed? what it do?
        // setTimeout(function () {
        //   location.reload();
        // }, 15000);
        hostMessages.add('HostId already in use, retrying in 15 seconds...!');
      } else {
        hostMessages.add(error.toString());
      }
    });
    host?.onDiagnostic(handler: ({required String message}) {
      print('onDiagnostic! $message');
      hostMessages.add(message);
    });
    host?.onConnection(handler: ({required UhstSocket uhstSocket}) {
      print('onConnection! $uhstSocket');
      uhstSocket.onDiagnostic(handler: ({required String message}) {
        hostMessages.add(message);
      });
      uhstSocket.onMessage(handler: ({required Message? message}) {
        print('onMessage! $message');
        hostMessages.add("Host received: ${message.toString()}");
      });
      uhstSocket.onOpen(handler: ({required String? data}) {
        print('onMessage! $data');
        uhstSocket.sendString(message: 'Host sent message!');
      });
    });
  }

  Future<void> join() async {
    client = await uhst.join(hostId: 'testHost');
    client?.onError(handler: ({required Error error}) {
      if (error is InvalidHostId || error is InvalidClientOrHostId) {
        clientMessages.add('Invalid hostId!');
      } else {
        clientMessages.add(error.toString());
      }
    });
    client?.onDiagnostic(handler: ({required String message}) {
      clientMessages.add(message);
    });
    client?.onOpen(handler: ({required String data}) {
      client?.sendString(message: 'Hello host!');
    });
    client?.onMessage(handler: ({required Message? message}) {
      clientMessages.add('Client received: $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          Flexible(
              flex: 1,
              child: Material(
                  elevation: 4,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Text('Client test'),
                        Divider(
                          height: 22,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: ElevatedButton(
                              onPressed: () async => await join(),
                              child: Text('Click to start')),
                        ),
                        Divider(
                          height: 22,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              return Text(hostMessages[index]);
                            },
                            itemCount: hostMessages.length,
                          ),
                        )
                      ],
                    ),
                  ))),
          Flexible(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text('Host test'),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton(
                          onPressed: () => initHost(), child: Text('Run host')),
                    ),
                    TextField(
                      decoration:
                          InputDecoration(labelText: 'enter server address'),
                      controller: _textController,
                    ),
                    Divider(
                      height: 22,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          return Text(hostMessages[index]);
                        },
                        itemCount: hostMessages.length,
                      ),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
