# uhst-client-flutter

User Hosted Secure Transmission (uhst) for Flutter in Dart

# Documentation

## Styling

This project uses (Dart documentation style guidlines)[https://dart.dev/guides/language/effective-dart/documentation]

## Generation

The project uses (dartdoc)[https://github.com/dart-lang/dartdoc#dartdoc]

If you don't have installed dartdoc, then to install the latest version of dartdoc compatible with your SDK run:

- `pub global activate dartdoc`
- for Flutter Snap version run `flutter pub global activate dartdoc`

To generate documentation

- run `dartdoc`
- for Flutter Snap version run `flutter pub global run dartdoc:dartdoc`

## View

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
