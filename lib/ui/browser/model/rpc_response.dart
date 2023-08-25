
class RpcResponse {
  final int id;
  final String jsonrpc;
  final dynamic result;
  Error? error;

  factory RpcResponse.fromJson(dynamic response) {
    return RpcResponse(
        id: response["id"],
        jsonrpc: response["jsonrpc"],
        result: response["result"],
        error: response["error"]);
  }

  dynamic toJson(){
    return {
      "id": id,
      "jsonrpc": jsonrpc,
      "result": result,
      "error": error
    };
  }
  RpcResponse(
      {required this.id,
      required this.jsonrpc,
      required this.result,
      this.error});
}

class Error {
  final int code;
  dynamic data;
  Error(this.code);
}
