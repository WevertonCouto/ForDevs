// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

import '../entities/entities.dart';

abstract class Authentication {
  Future<AccountEntity> auth(AuthenticationParams authenticationParams);
}

class AuthenticationParams {
  String email;
  String secret;

  AuthenticationParams({
    @required this.email,
    @required this.secret,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'password': secret,
    };
  }

  factory AuthenticationParams.fromMap(Map<String, dynamic> map) {
    return AuthenticationParams(
      email: map['email'] as String,
      secret: map['password'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory AuthenticationParams.fromJson(String source) =>
      AuthenticationParams.fromMap(json.decode(source) as Map<String, dynamic>);
}
