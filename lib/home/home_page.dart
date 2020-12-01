import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  User _user;
  DatabaseReference _firebaseMsgDbRef;
  bool _isComposing = false;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    //initialize
    dynamic _now = DateTime.now().toUtc();
    _user = FirebaseAuth.instance.currentUser;
    _firebaseMsgDbRef = FirebaseDatabase.instance
        .reference()
        .child('messages/${_now.year}/${_now.month}/${_now.day}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text("Chatting as ${_user.displayName}"),
        ),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            _buildMessagesList(),
            _buildComposeMsgRow(),
          ],
        ),
      ),
    );
  }
  // Builds the list of chat messages.

  Widget _buildMessagesList() {
    return Flexible(
      child: Scrollbar(
        child: FirebaseAnimatedList(
          defaultChild: const Center(child: CircularProgressIndicator()),
          query: _firebaseMsgDbRef,
          sort: (a, b) => b.key.compareTo(a.key),
          padding: const EdgeInsets.all(8.0),
          reverse: true,
          itemBuilder: (BuildContext ctx, DataSnapshot snapshot,
                  Animation<double> animation, int idx) =>
              _messageFromSnapshot(snapshot, animation),
        ),
      ),
    );
  }

  // Returns the UI of one message from a data snapshot.

  Widget _messageFromSnapshot(
    DataSnapshot snapshot,
    Animation<double> animation,
  ) {
    final senderName = snapshot.value['senderName'] as String ?? '?? <unknown>';
    final msgText = snapshot.value['text'] as String ?? '??';
    final sentTime = snapshot.value['timestamp'] as int ?? 0;
    final senderPhotoUrl = snapshot.value['senderPhotoUrl'] as String;
    final messageUI = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: senderPhotoUrl != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(senderPhotoUrl),
                  )
                : CircleAvatar(
                    child: Text(senderName[0]),
                  ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(senderName, style: Theme.of(context).textTheme.subtitle1),
                Text(
                  DateTime.fromMillisecondsSinceEpoch(sentTime).toString(),
                  style: Theme.of(context).textTheme.caption,
                ),
                Text(msgText),
              ],
            ),
          ),
        ],
      ),
    );
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: messageUI,
    );
  } // Builds the row for composing and sending message.

  Widget _buildComposeMsgRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: TextField(
              keyboardType: TextInputType.multiline,
              // Setting maxLines=null makes the text field auto-expand when one
              // line is filled up.
              maxLines: null,
              maxLength: 200,
              decoration:
                  const InputDecoration.collapsed(hintText: "Send a message"),
              controller: _textController,
              onChanged: (String text) =>
                  setState(() => _isComposing = text.isNotEmpty),
              onSubmitted: _onTextMsgSubmitted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isComposing
                ? () => _onTextMsgSubmitted(_textController.text)
                : null,
          ),
        ],
      ),
    );
  }

  // Triggered when text is submitted (send button pressed).
  Future<void> _onTextMsgSubmitted(String text) async {
    // Make sure _user is not null.
    if (this._user == null) {
      this._user = FirebaseAuth.instance.currentUser;
    }
    if (this._user == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Login required'),
          content: const Text('To send messages you need to first log in.\n\n'
              'Go to the "Firebase login" example, and log in from there. '
              'You will then be able to send messages.'),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            )
          ],
        ),
      );
      return;
    }
    // Clear input text field.
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    // Send message to firebase realtime database.
    _firebaseMsgDbRef.push().set({
      'senderId': this._user.uid,
      'senderName': this._user.displayName,
      'senderPhotoUrl': this._user.photoURL,
      'text': text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
