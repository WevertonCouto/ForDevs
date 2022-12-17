import 'dart:convert';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

import '../../data/http/http.dart';

class HttpAdapter implements HttpClient {
  final Client client;

  HttpAdapter(this.client);

  Future<Map<String, dynamic>> request(
      {@required String url, @required String method, Map body}) async {
    final headers = {
      'content-type': 'application/json',
      'accept': 'application/json',
    };
    final jsonBody = body != null ? jsonEncode(body) : null;

    final response = await client.post(
      url,
      headers: headers,
      body: jsonBody,
    );
    return response.statusCode == 204 || response.body.isEmpty
        ? null
        : jsonDecode(response.body);
  }
}
