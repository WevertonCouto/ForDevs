class AccountEntity {
  final String token;

  AccountEntity(this.token);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'token': token,
    };
  }

  factory AccountEntity.fromMap(Map<String, dynamic> map) {
    return AccountEntity(
      map['accessToken'] as String,
    );
  }
}
