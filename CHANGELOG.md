# 3.4.0

- feat: onClose callbacks now have hostId parameter
- feat(relay socket): if host drops connection new HostDisconnected exception will be raised.

# 3.3.0

- feat: onClose callbacks for client and host relay sockets
- feat: dispose method for client and host.
  This method should be called during dispose method in Flutter widget or any another cases that require to cancel all subscriptions and all methods.
- refactor: client/host action buttons for example & example improvements
- fix(host relay socket): drop connection on server error

# 3.2.1

- feat: remoteId added to socket
- fix: open event not triggering on client connected

# 3.2.0

- feat: connect to closest relay based on ping to 10 random relays

# 3.1.0

- BREAKING CHANGE: all `Error` methods and functions renamed to `Exception`.
  The reason of it is a nature between Exception and Error in dart.
  In short:
  `Exceptions` should be used when there is a problem that is expected.
  A common one is any type of I/O operation (like network traffic), where the socket closes early, and trying to write data to that socket fails.
  `Errors` occur when there is a problem that was not expected. Things like null pointers (you expected this variable to not be null), running our of memory, etc... When you try to use the API in a wrong way or stuffs like that.
  `For the most part` you, as an app developer, will always `use exceptions`.
  Errors tend to be reserved for unexpected and fatal problems.
  source:
  https://stackoverflow.com/questions/17315945/error-vs-exception-in-dart
- BREAKING CHANGE: Dart API >= 2.13.0
- feat: flutter_lints and analysis_options to get most better way style the code
- fix: linter errors and code style improvements
- fix: some Errors were replaced by Exceptions, some Exceptions became Errors to make more correct way of using Exceptions and Errors

# 3.0.0

- BREAKING CHANAGE: rename Uhst to UHST
- fix: "Bad state: Future already completed" #15
- fix: error handling, prior to this version error handling is unusable

# 2.0.0

- BREAKING CHANAGE: null safety support fully enabled

# 1.0.2-nullsafety.0

- fix: uhstSocket.onMessage exposes the internal UHST message to the client #10

# 1.0.1-nullsafety.0

- fix: Host received client connection from clientId after message sent #9

# 1.0.0-nullsafety.0

- BREAKING CHANAGE: Rename apiUrl to relayUrl in preparation for adding UHST API support.

# 0.0.1-nullsafety.1

- fix: The package description is too short.
- fix: The value of the local variable 'onOpenSubcription' isn't used (relay_client).
- fix: cancel subscribe warning.
- feat: test for jwt util
- feat: type definitions test
- fix: payload type conversion
- fix: typing for uhst host create

# 0.0.1-nullsafety.0

- Initial development release.
