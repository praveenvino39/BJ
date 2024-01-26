import 'dart:math';

import 'package:wallet_cryptomask/ui/browser/model/request.dart';

const int kIntMaxValue = 9007199254740991;

class RpcRequest {
  int? id;
  final String jsonrpc = "2.0";
  final String method;
  final dynamic params;

  RpcRequest({required this.method, required this.params}) {
    id = Random().nextInt(kIntMaxValue);
  }

  factory RpcRequest.fromRequest(Request request) {
    return RpcRequest(method: request.method, params: request.params);
  }

  toJson() {
    return {
      "id": Random().nextInt(9999999),
      "jsonrpc": jsonrpc,
      "method": method,
      "params": params
    };
  }
}

// {
//      "id": 1,
//      "jsonrpc": "2.0",
//      "method": "eth_chaind",
//      "params": []
// }