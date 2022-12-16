import '../../data/http/http.dart';
import '../../domain/entities/entities.dart';

class RemoteAccountModel {
  final String accessToken;

  RemoteAccountModel(this.accessToken);

  factory RemoteAccountModel.fromMap(Map<String, dynamic> map) {
    if (!map.containsKey('accessToken')) {
      throw HttpError.invalidData;
    }
    return RemoteAccountModel(
      map['accessToken'] as String,
    );
  }

  AccountEntity toEntity() {
    return AccountEntity(accessToken);
  }
}
