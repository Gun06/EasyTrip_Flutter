import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../helpers/database_helper.dart';
import '../models/user.dart';

class AdminChatPage extends StatefulWidget {
  final User user;

  AdminChatPage({required this.user});

  @override
  _AdminChatPageState createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final dbHelper = DatabaseHelper.instance;
    final messages = await dbHelper.getMessages(widget.user.id!);
    setState(() {
      _messages.addAll(messages);
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: '메시지를 입력하세요.');
      return;
    }

    setState(() {
      _isSending = true;
      _messages.add({
        "sender": "admin",
        "message": _messageController.text.trim(),
        "timestamp": DateTime.now().toIso8601String()
      });
    });

    final dbHelper = DatabaseHelper.instance;
    await dbHelper.insertMessage(widget.user.id!, "admin", _messageController.text.trim());

    _messageController.clear();
    setState(() {
      _isSending = false;
    });
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isAdmin = message["sender"] == "admin";
    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isAdmin ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          message["message"],
          style: TextStyle(color: isAdmin ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.nickname),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                _isSending
                    ? CircularProgressIndicator()
                    : IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
