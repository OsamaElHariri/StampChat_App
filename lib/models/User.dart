class User {
  num id;
  DateTime dateCreated;
  String name;

  User({this.id, this.name, this.dateCreated});

  factory User.fromJson(Map map) {
    return User(
      id: map['id'],
      name: map['friendly_name'],
      dateCreated: map['dateCreated'],
    );
  }
}
