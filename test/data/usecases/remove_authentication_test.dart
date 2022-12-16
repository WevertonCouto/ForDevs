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
  setUp(() {
    httpClient = HttpClientSpy();
    url = faker.internet.httpUrl();
    sut = RemoteAuthentication(httpClient: httpClient, url: url);
    params = AuthenticationParams(
      email: faker.internet.email(),
      secret: faker.internet.password(),
    );
  });

  test('Should call HttpClient with correct values', () async {
    // arrange
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenAnswer((_) async {
      return {'accessToken': faker.guid.guid(), 'name': faker.person.name()};
    });

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
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.badRequest);

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
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.notFound);

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
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.serverError);

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
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenThrow(HttpError.unauthorized);

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
    final accessToken = faker.guid.guid();
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenAnswer(
        (_) async => {'accessToken': accessToken, 'name': faker.person.name()});

    // act
    final account = await sut.auth(params);

    //assert
    expect(account.token, accessToken);
  });

  test(
      'Should throw UnexpectedError if HttpClient returns 200 with invalid data',
      () async {
    // arrange
    when(httpClient.request(
      url: anyNamed('url'),
      method: anyNamed('method'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => {'invalid_key': 'invalid_value'});

    // act
    final future = sut.auth(params);

    //assert
    expect(future, throwsA(DomainError.unexpected));
  });
}
