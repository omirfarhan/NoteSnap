import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class GoogleHttpClient extends IOClient {
  final Map<String, String> _headers;

  GoogleHttpClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) {
    headers ??= {};
    headers.addAll(_headers);
    return super.head(url, headers: headers);
  }
}
