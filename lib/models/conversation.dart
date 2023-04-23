class Conversations {
  final List<Conversation> conversations;

  factory Conversations.fromJson(Map<String, dynamic> data) {
    List<Conversation> conversations = List.empty(growable: true);
    data.forEach((key, value) {
      conversations.add(Conversation(value['name'], key));
    });

    return Conversations(conversations);
  }

  Conversations(this.conversations);

  int get length {
    return conversations.length;
  }
}

class Conversation {
  final String name;
  final String id;

  Conversation(this.name, this.id);
}
