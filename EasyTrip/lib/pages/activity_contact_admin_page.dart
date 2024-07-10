import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../helpers/database_helper.dart';

class ContactAdminPage extends StatefulWidget {
  final int userId;

  ContactAdminPage({required this.userId});

  @override
  _ContactAdminPageState createState() => _ContactAdminPageState();
}

class _ContactAdminPageState extends State<ContactAdminPage> {
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
    final messages = await dbHelper.getMessages(widget.userId);
    setState(() {
      _messages.addAll(messages);
    });
    await dbHelper.markMessagesAsRead(widget.userId, 'admin');
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: '메시지를 입력하세요.');
      return;
    }

    setState(() {
      _isSending = true;
      _messages.add({
        "sender": "user",
        "message": _messageController.text.trim(),
        "timestamp": DateTime.now().toIso8601String()
      });
    });

    final dbHelper = DatabaseHelper.instance;
    await dbHelper.insertMessage(widget.userId, "user", _messageController.text.trim());

    _messageController.clear();
    setState(() {
      _isSending = false;
    });
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isUser = message["sender"] == "user";
    bool isRead = message["isRead"] == 1;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUser && !isRead) Icon(Icons.mark_chat_unread, color: Colors.white, size: 16),
            if (!isUser && !isRead) Icon(Icons.mark_chat_unread, color: Colors.black, size: 16),
            SizedBox(width: 5),
            Text(
              message["message"],
              style: TextStyle(color: isUser ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          '문의하기',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
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
