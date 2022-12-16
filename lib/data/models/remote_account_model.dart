import 'package:fordev_app/domain/entities/account_entity.dart';

class RemoteAccountModel {
  final String accessToken;

  RemoteAccountModel(this.accessToken);

  factory RemoteAccountModel.fromMap(Map<String, dynamic> map) {
    return RemoteAccountModel(
      map['accessToken'] as String,
    );
  }

  AccountEntity toEntity() {
    return AccountEntity(accessToken);
  }
}
