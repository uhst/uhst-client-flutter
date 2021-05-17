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
