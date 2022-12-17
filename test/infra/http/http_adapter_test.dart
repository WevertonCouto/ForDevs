import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:meta/meta.dart';

import 'package:fordev_app/data/http/http.dart';

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
    return response.body.isEmpty ? null : jsonDecode(response.body);
  }
}

class ClientSpy extends Mock implements Client {}

void main() {
  HttpAdapter sut;
  ClientSpy client;
  String url;
  setUp(() {
    client = ClientSpy();
    sut = HttpAdapter(client);
    url = faker.internet.httpUrl();
  });

  group('post', () {
    PostExpectation mockRequest() => when(
          client.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')),
        );

    void mockResponse(
      int statusCode, {
      String body = '{"any_key": "any_value"}',
    }) {
      mockRequest().thenAnswer(
        (_) async => Response(body, statusCode),
      );
    }

    setUp(() {
      mockResponse(200);
    });

    test('Should call post with correct values', () async {
      final body = {'any_key': 'any_value'};

      // act
      await sut.request(
        url: url,
        method: 'post',
        body: body,
      );

      // assert
      verify(
        client.post(
          url,
          headers: {
            'content-type': 'application/json',
            'accept': 'application/json',
          },
          body: jsonEncode(body),
        ),
      );
    });

    test('Should call post without body', () async {
      // act
      await sut.request(
        url: url,
        method: 'post',
      );

      // assert
      verify(
        client.post(
          any,
          headers: anyNamed('headers'),
        ),
      );
    });

    test('Should return data if post returns 200', () async {
      // arrange
      final body = {'any_key': 'any_value'};

      // act
      final response = await sut.request(
        url: url,
        method: 'post',
      );

      // assert
      expect(
        response,
        body,
      );
    });

    test('Should return null if post returns 200 with no data', () async {
      // arrange
      mockResponse(200, body: '');

      // act
      final response = await sut.request(
        url: url,
        method: 'post',
      );

      // assert
      expect(
        response,
        null,
      );
    });

    test('Should return null if post returns 204', () async {
      // arrange
      mockResponse(204, body: '');

      // act
      final response = await sut.request(
        url: url,
        method: 'post',
      );

      // assert
      expect(
        response,
        null,
      );
    });
  });
}
