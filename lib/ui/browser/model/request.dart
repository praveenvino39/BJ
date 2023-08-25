class Request {
  final String method;
  final dynamic params;

  Request(this.method, this.params);

  factory Request.fromJson(dynamic request){
    String method = request["method"];
    dynamic params = request["params"];
    return Request(method, params);
  }
}