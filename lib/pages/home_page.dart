import 'package:flutter/material.dart';
import 'package:escripvain/api/requests.dart';
import 'package:escripvain/constants.dart';
import 'package:escripvain/models/conversation.dart';
import 'package:escripvain/pages/conversation_page.dart';
import 'package:escripvain/partials/appbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Conversation> _conversations;
  late bool _loading;

  @override
  void initState() {
    _conversations = List.empty(growable: true);
    _loading = true;
    fetchConversation();
    super.initState();
  }

  void fetchConversation() async {
    setState(() {
      _loading = true;
    });
    var res = await getConversations(uuid as String);
    setState(() {
      _loading = false;
      if (res != null) {
        _conversations = res.conversations;
      }
    });
  }

  Widget createList(List<Conversation> convs) {
    if (convs.isEmpty) {
      return const Center(
          child: Text(
              "La liste est vide ! Créer une nouvelle conversation pour commencer !"));
    }
    return ListView.separated(
      separatorBuilder: (context, index) => const Divider(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Dismissible(
            key: Key(UniqueKey().toString()),
            background: Container(
              color: Colors.red,
              child: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.delete,
                        color: Colors.white,
                      )
                    ],
                  )),
            ),
            confirmDismiss: (direction) =>
                deleteConversation(uuid as String, convs[index].id.toString()),
            onDismissed: (direction) => removeConversation(index),
            child: ListTile(
              title: Text(convs[index].name),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ConversationPage(conversation: convs[index]),
                    ));
              },
            ));
      },
      itemCount: convs.length,
    );
  }

  void createConversation() {
    var res = addConversation(uuid as String);
    res.then((value) {
      if (value != null) {
        setState(() {
          _conversations.add(value);
        });

        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConversationPage(conversation: value),
            ));
      }
    });
  }

  removeConversation(int index) {
    setState(() {
      _conversations.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appbar,
        floatingActionButton: ClipOval(
            child: Container(
          height: 54,
          width: 54,
          color: Colors.purple,
          child: IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              createConversation();
            },
          ),
        )),
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height -
                    appbar.preferredSize.height),
            child: Stack(
              children: [
                Visibility(
                    visible: _loading,
                    child: Column(children: const [
                      Expanded(
                          child: Center(
                        child: CircularProgressIndicator(),
                      ))
                    ])),
                Visibility(
                  visible: !_loading,
                  child: Container(child: createList(_conversations)),
                )
              ],
            ),
          ),
        ));
  }
}
