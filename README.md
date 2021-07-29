# UHST

> User Hosted Secure Transmission (UHST) for Flutter in Dart

[![Pub](https://img.shields.io/pub/v/uhst.svg)](https://pub.dartlang.org/packages/uhst)
[![Gitter](https://badges.gitter.im/uhst/community.svg)](https://gitter.im/uhst/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![GitHub](https://img.shields.io/github/license/uhst/uhst-client-flutter)](LICENSE)

## About

UHST is client library for the User Hosted Secure Transmission framework.

It is able to:

- send messages from client and listen for messages broadcasted from host
- broadcast messages by host
- listen messages from multiple clients by host

You can see [an implemented example](https://docs.uhst.io/uhst-client-flutter/) and source for it [on GitHub](https://github.com/uhst/uhst-client-flutter/tree/next/example)

Please notice current version limitations:

- it supports string typed messages only.
- require server with UHST implemented protocol. PLease see an example of ready to go server [on GitHub](https://github.com/uhst/uhst-server-node).

### Support and discussions

Join us on [Gitter](https://gitter.im/uhst/community?utm_source=share-link&utm_medium=link&utm_campaign=share-link) or StackOverflow .

## Usage

Assuming you have loaded the library, first create a new instance:

```dart
var uhst = UHST();
```

Refer to the documentation to learn about the options you can pass
(including your own Relay server URL, WebRTC configuration, etc.) .

### Host

Host in UHST is a peer which every other peer connects to.
This concept is similar to listen-server in multiplayer games.

Please be sure, before reconnecting to another host, to close previous connection.

The simplest way to create a new host is:

```dart
var host = uhst.host("testHost");

host?.disconnect();

host
  ?..onReady(handler: ({required String hostId}) {
    setState(() {
      hostMessages.add('Host Ready! Using $hostId');
      print('host is ready!');
      _hostIdController.text = hostId;
    });
  })
  ..onException(handler: ({required dynamic exception}) {
    print('exception received! $exception');
    if (exception is HostIdAlreadyInUse) {
      // this is expected if you refresh the page
      // connection is still alive on the relay
      // just need to wait
      setState(() {
        hostMessages
            .add('HostId already in use, retrying in 15 seconds...!');
      });
    } else {
      setState(() {
        hostMessages.add(exception.toString());
      });
    }
  })
  ..onConnection(handler: ({required UhstSocket uhstSocket}) {
    uhstSocket.onDiagnostic(handler: ({required String message}) {
      setState(() {
        hostMessages.add(message);
      });
    });

    uhstSocket.onMessage(handler: ({required message}) {
      setState(() {
        hostMessages
            .add("Host received: $message");
        host?.broadcastString(message: message);
      });
    });

    uhstSocket.onOpen(handler: () {
      // uhstSocket.sendString(message: 'Host sent message!');
    });
  });
}
```

Note that your requested host id may not be accepted by the signalling server,
you should always use the `hostId` you get after receiving a `ready`
event when connecting to the host.

### Client

To connect to a host from another browser use the same `hostId`
you received during `onReady` event.

Please be sure, before reconnecting to another host, to close previous connection.

```dart
var client = uhst.join("testHost");

client?.close();

client
  ?..onOpen(handler: () {
    setState(() {
      client?.sendString(message: 'Hello host!');
    });
  })
  ..onMessage(handler: ({required message}) {
    setState(() {
      clientMessages.add('Client received: $message');
    });
  })
  ..onException(handler: ({required dynamic exception}) {
    if (exception is InvalidHostId || exception is InvalidClientOrHostId) {
      setState(() {
        clientMessages.add('Invalid hostId!');
      });
    } else {
      setState(() {
        clientMessages.add(exception.toString());
      });
    }
  })
  ..onDiagnostic(handler: ({required String message}) {
    setState(() {
      clientMessages.add(message);
    });
  });
```

The UHST client interface is similar to the HTML5 WebSocket interface,
but instead of a dedicated server, one peer acts as a host for other peers to join.

Once a client and a host have connected they can exchange messages asynchronously.
Arbitrary number of clients can connect to the same host but clients
cannot send messages to each other, they can only communicate with the host.

## Documentation

Visit our website for more complete documentation: [https://docs.uhst.io](https://docs.uhst.io).

### Styling

This project uses (Dart documentation style guidlines)[https://dart.dev/guides/language/effective-dart/documentation]

### Generation

The project uses (dartdoc)[https://github.com/dart-lang/dartdoc#dartdoc]

If you don't have installed dartdoc, then to install the latest version of dartdoc compatible with your SDK run:

- `pub global activate dartdoc`
- for Flutter Snap version run `flutter pub global activate dartdoc`

To generate documentation

- run `dartdoc`
- for Flutter Snap version run `flutter pub global run dartdoc:dartdoc`

### View

An easy way to run an HTTP server locally is to use the dhttpd package. For example:

```shell
$ pub global activate dhttpd
$ dhttpd --path doc/api
```

for Flutter Snap

```shell
$ flutter pub global activate dhttpd
$ flutter pub global run dhttpd:dhttpd --path doc/api
```

## Contributing

This project is maintained by a community of developers. Contributions are welcome and appreciated.
You can find UHST on GitHub; feel free to start an issue or create a pull requests:<br>
[https://github.com/uhst/uhst-client-flutter](https://github.com/uhst/uhst-client-flutter).

## License

Copyright (c) 2020 UHST
Licensed under [MIT License](LICENSE).
