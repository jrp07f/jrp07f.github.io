import 'package:http/browser_client.dart';
import 'package:http/http.dart';

Client get platformClient => BrowserClient()..withCredentials = true;