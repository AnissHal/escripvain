class Messages {
  final List<Message> messages;

  Messages(this.messages);

  factory Messages.fromJson(Map<String, dynamic> data) {
    List<Message> _messages = List.empty(growable: true);

    data.forEach((key, value) {
      _messages.add(Message(key.toString(), value['text'], value['audio_link'],
          value['user_id'], DateTime.parse(value['date'])));
    });
    return Messages(_messages);
  }

  int get length {
    return messages.length;
  }
}

class Message {
  final String id;
  final String? text;
  final String? audioLink;
  final int userID;
  final DateTime date;

  Message(this.id, this.text, this.audioLink, this.userID, this.date);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'audio_link': audioLink,
      'user_id': userID,
      'date': date
    };
  }

  factory Message.fromJson(Map<String, dynamic> data) {
    return Message(data['id'].toString(), data['text'], data['audio_link'],
        data['user_id'], DateTime.parse(data['date']));
  }

  factory Message.Empty() {
    return Message('f'.toString(), '', null, -1, DateTime.now());
  }
}
