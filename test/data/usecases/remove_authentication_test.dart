import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:fordev_app/data/usecases/usecases.dart';
import 'package:fordev_app/data/http/http.dart';
import 'package:fordev_app/domain/usecases/usecases.dart';
import 'package:fordev_app/domain/helpers/helpers.dart';

class HttpClientSpy extends Mock implements HttpClient {}

void main() {
  RemoteAuthentication sut;
  HttpClientSpy httpClient;
  String url;
  AuthenticationParams params;

  Map<String, dynamic> mockValidData() =>
      {'accessToken': faker.guid.guid(), 'name': faker.person.name()};

  PostExpectation mockRequest() => when(httpClient.request(
        url: anyNamed('url'),
        method: anyNamed('method'),
        body: anyNamed('body'),
      ));

  void mockHttpData(Map<String, dynamic> data) {
    mockRequest().thenAnswer((_) async {
      return data;
    });
  }

  void mockHttpError(HttpError error) {
    mockRequest().thenThrow(error);
  }

  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
      email: faker.internet.email(),
      secret: faker.internet.password(),
    );
    mockHttpData(mockValidData());
  });

  test('Should call HttpClient with correct values', () async {
    // act
    await sut.auth(params);

    //assert
    verify(
      httpClient.request(url: url, method: 'post', body: {
        'email': params.email,
        'password': params.secret,
      }),
    );
  });

  test('Should throw UnexpectedError if HttpClient returns 400', () async {
    // arrange
    mockHttpError(HttpError.badRequest);

    // act
    final future = sut.auth(params);

    //assert
    expect(
      future,
      throwsA(DomainError.unexpected),
    );
  });

  test('Should throw UnexpectedError if HttpClient returns 404', () async {
    // arrange
    mockHttpError(HttpError.notFound);

    // act
    final future = sut.auth(params);

    //assert
    expect(
      future,
      throwsA(DomainError.unexpected),
    );
  });

  test('Should throw UnexpectedError if HttpClient returns 500', () async {
    // arrange
    mockHttpError(HttpError.serverError);

    // act
    final future = sut.auth(params);

    //assert
    expect(
      future,
      throwsA(DomainError.unexpected),
    );
  });

  test('Should throw InvalidCredentialsError if HttpClient returns 401',
      () async {
    // arrange
    mockHttpError(HttpError.unauthorized);

    // act
    final future = sut.auth(params);

    //assert
    expect(
      future,
      throwsA(DomainError.invalidCredentials),
    );
  });

  test('Should return and Account if HttpClient returns 200', () async {
    // arrange
    final validData = mockValidData();
    mockHttpData(validData);

    // act
    final account = await sut.auth(params);

    //assert
    expect(account.token, validData['accessToken']);
  });

  test(
      'Should throw UnexpectedError if HttpClient returns 200 with invalid data',
      () async {
    // arrange
    mockHttpData({'invalid_key': 'invalid_value'});

    // act
    final future = sut.auth(params);

    //assert
    expect(future, throwsA(DomainError.unexpected));
  });
}
