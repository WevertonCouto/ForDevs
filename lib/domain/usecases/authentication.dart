// ignore_for_file: public_member_api_docs, sort_constructors_first
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
}
