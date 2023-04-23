class User {
  final int id;
  final String username;
  final String uuid;

  User(this.id, this.username, this.uuid);

  factory User.fromApi(Map<String, dynamic> data) {
    return User(data['id'], data['username'], data['uuid']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'uuid': uuid,
    };
  }
}
