import 'package:http/http.dart';

class BrowserClient extends BaseClient {
  bool get withCredentials {
    throw UnimplementedError();
  }

  set withCredentials(value) {
    throw UnimplementedError();
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    throw UnimplementedError();
  }
}
