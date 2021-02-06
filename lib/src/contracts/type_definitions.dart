library uhst;

/// Defines callback to handle [FromJson] function
/// This function is needed to convert [Map] in defined type or model
typedef T FromJson<T>(Map<String, dynamic> map);

/// [PayloadType] is a type of message data which can be send and handled by
/// Client (for example [RelaySocket] or by Host [UhstHost]
enum PayloadType { string, blob }
