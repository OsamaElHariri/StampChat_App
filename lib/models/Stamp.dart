class Stamp {
  int id;
  int memberId;
  int messageId;
  String word;
  num xPos;
  num yPos;
  double strength = 0.0;

  Stamp({
    this.id,
    this.strength = 0.0,
    this.word,
    this.xPos,
    this.yPos,
    this.messageId,
    this.memberId,
  }) {
    this.strength = this.strength.clamp(0.0, 1.0);
  }

  factory Stamp.fromJson(Map map) {
    return Stamp(
      id: map['id'],
      memberId: map['member_id'],
      messageId: map['message_id'],
      word: map['word'],
      xPos: map['x_pos'],
      yPos: map['y_pos'],
      strength: map['strength'] ?? 0,
    );
  }
}
