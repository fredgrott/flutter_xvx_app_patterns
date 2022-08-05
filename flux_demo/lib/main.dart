// ignore_for_file: unnecessary_new, prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:flux_demo/flux/store.dart';
import 'package:flux_demo/flux/store_watcher.dart';
import 'package:flux_demo/stores.dart';

void main() {
  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
      title: 'Chat',
      theme: new ThemeData(
          primarySwatch: Colors.purple,),
      home: new ChatScreen(),),);
}

class ChatScreen extends StatefulWidget {
  /// Creates a widget that watches stores.
  ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => new ChatScreenState();
}

// To use StoreWatcherMixin in your widget's State class:
// 1. Add "with StoreWatcherMixin<yyy>" to the class declaration where yyy is
//    the type of your StatefulWidget.
// 2. Add the Store declarations to your class.
// 3. Add initState() function that calls listenToStore() for each store to
//    be monitored.
// 4. Use the information from your store(s) in your build() function.

class ChatScreenState extends State<ChatScreen>
    with StoreWatcherMixin<ChatScreen> {
  // Never write to these stores directly. Use Actions.
  late ChatMessageStore messageStore;
  late ChatUserStore chatUserStore;

  final TextEditingController msgController = TextEditingController();

  /// Override this function to configure which stores to listen to.
  ///
  /// This function is called by [StoreWatcherState] during its
  /// [State.initState] lifecycle callback, which means it is called once per
  /// inflation of the widget. As a result, the set of stores you listen to
  /// should not depend on any constructor parameters for this object because
  /// if the parent rebuilds and supplies new constructor arguments, this
  /// function will not be called again.
  @override
  void initState() {
    super.initState();

    // Demonstrates using a custom change handler.
    messageStore =
        listenToStore(messageStoreToken, handleChatMessageStoreChanged,) as ChatMessageStore;

    // Demonstrates using the default handler, which just calls setState().
    chatUserStore = listenToStore(userStoreToken) as ChatUserStore;
  }

  void handleChatMessageStoreChanged(Store store) {
    final ChatMessageStore messageStore = store as ChatMessageStore;
    if (messageStore.currentMessage.isEmpty) {
      msgController.clear();
    }
    setState(() {});
  }

  Widget _buildTextComposer(BuildContext context, ChatMessageStore messageStore,
      ChatUserStore userStore,) {
    final ValueChanged<String> commitMessage = (String _) {
      commitCurrentMessageAction(userStore.me);
    };

    final ThemeData themeData = Theme.of(context);

    return Row(children: <Widget>[
      Flexible(
          child: TextField(
              key: const Key("msgField"),
              controller: msgController,
              decoration: const InputDecoration(hintText: 'Enter message'),
              onSubmitted: commitMessage,
              onChanged: setCurrentMessageAction,),),
      Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          child: IconButton(
              icon: const Icon(Icons.send),
              onPressed:
                  messageStore.isComposing ? () => commitMessage('') : null,
              color: messageStore.isComposing
                  ? themeData.colorScheme.secondary
                  : themeData.disabledColor,),),
    ],);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: new Text('Chatting as ${chatUserStore.me.name}')),
        body: Column(children: <Widget>[
          new Flexible(
              child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  children: messageStore.messages
                      .map((ChatMessage m) => new ChatMessageListItem(m))
                      .toList(),),),
          _buildTextComposer(context, messageStore, chatUserStore),
        ],),);
  }
}

// ignore: prefer-single-widget-per-file
class ChatMessageListItem extends StatefulWidget {
  ChatMessageListItem(ChatMessage m)
      : message = m,
        super(key: new ObjectKey(m));

  final ChatMessage message;

  @override
  State createState() => new ChatMessageListItemState();
}

class ChatMessageListItemState extends State<ChatMessageListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700),);
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeOut,);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatMessage message = widget.message;

    return new SizeTransition(
        sizeFactor: _animation,
        axisAlignment: 0.0,
        child: ListTile(
            dense: true,
            leading: CircleAvatar(
                child: Text(message.sender!.name![0]),
                backgroundColor: message.sender!.color,),
            title: Text(message.sender!.name as String),
            subtitle: Text(message.text as String),),);
  }
}
