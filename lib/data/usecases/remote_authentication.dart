// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

import 'package:fordev_app/domain/entities/account_entity.dart';

import '../../domain/usecases/usecases.dart';
import '../http/http.dart';

class RemoteAuthentication {
  final HttpClient httpClient;
  final String url;

  RemoteAuthentication({
    @required this.httpClient,
    @required this.url,
  });

  Future<void> auth(AuthenticationParams params) async {
    httpClient.request(
      url: url,
      method: 'post',
      body: RemoteAuthenticationParams.fromDomain(params).toMap(),
    );
  }
}

class RemoteAuthenticationParams {
  String email;
  String password;

  RemoteAuthenticationParams({
    @required this.email,
    @required this.password,
  });

  factory RemoteAuthenticationParams.fromDomain(AuthenticationParams params) =>
      RemoteAuthenticationParams(
        email: params.email,
        password: params.secret,
      );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'password': password,
    };
  }
}
