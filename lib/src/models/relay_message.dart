part of uhst_models;

@Deprecated('Use Message instead')
class RelayMessage {
  String? _payload;
  PayloadType? _payloadType;

  Future<void> setPayload({dynamic message}) async {
    if (message is String) {
      _payload = message;
      _payloadType = PayloadType.string;
    } else if (message is Blob) {
      _payloadType = PayloadType.blob;
      _payload = await blobToBase64(blob: message);
    } else {
      throw ArgumentError.value(
        message,
        'message',
        'unsupported',
      );
    }
  }

  Future getPayload() async {
    final payloadType = _payloadType;
    if (payloadType == null) {
      throw ArgumentError.notNull('payloadType');
    }
    switch (payloadType) {
      case PayloadType.string:
        return _payload;
      case PayloadType.blob:
      default:
        throw UnimplementedError('payloadType $payloadType');
      // const result = await fetch(_payload).then(res => res.blob());
      // return result;
    }
  }

  Future<String> blobToBase64({Blob? blob}) async {
    throw UnimplementedError('blobToBase64');
    // return new Promise((resolve) => {
    //   const reader = new FileReader();
    //   reader.readAsDataURL(blob);
    //   reader.onloadend = function () {
    //     resolve(reader.result as string);
    //   };
    // });
  }
}
