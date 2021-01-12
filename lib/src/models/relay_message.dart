library UHST;

import 'dart:html';

enum PayloadType { string, blob }

class RelayMessage {
  String? _payload;
  PayloadType? _payloadType;

  Future<void> setPayload({dynamic? message}) async {
    if (message is String) {
      _payload = message;
      _payloadType = PayloadType.string;
    } else if (message is Blob) {
      _payloadType = PayloadType.blob;
      _payload = await this.blobToBase64(blob: message);
    } else {
      throw Exception("Unsupported message type.");
    }
  }

  Future getPayload() async {
    var payloadType = _payloadType;
    if (payloadType == null)
      throw Exception('.getPayload Payload type is not defined!');
    switch (payloadType) {
      case PayloadType.string:
        return _payload;
      case PayloadType.blob:
        print(_payload);
      // TODO: implement method
      // const result = await fetch(_payload).then(res => res.blob());
      // return result;
    }
  }

  Future<String> blobToBase64({Blob? blob}) async {
    // TODO: implement method
    return '';
    // return new Promise((resolve) => {
    //   const reader = new FileReader();
    //   reader.readAsDataURL(blob);
    //   reader.onloadend = function () {
    //     resolve(reader.result as string);
    //   };
    // });
  }
}
