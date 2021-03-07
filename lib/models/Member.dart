import 'package:StampChat/models/User.dart';

class Member {
  num id;
  User user;

  Member({this.id, this.user});

  factory Member.fromJson(Map map) {
    return Member(
      id: map['id'],
      user: User.fromJson(map['user']),
    );
  }
}
