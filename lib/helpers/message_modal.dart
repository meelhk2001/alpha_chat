
class Message {   
  final String id;
  final String idFrom;
  final String idTo;
  final String timestamp;
final String   content;
final String   read;
final String type;
  const Message(
    this.id,
    this.content,
    this.idFrom,
    this.idTo,
    this.read,
    this.timestamp,
    this.type
  );
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      json['id'],
      json['content'],
      json['idFrom'],
      json['idTo'],
      json['read'],
      json['timestamp'],
      json['type']
    );
  }
}