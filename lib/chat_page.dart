import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:blur/blur.dart';
import 'package:connect/websocket_service.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config_file.dart';  // Configuration for API
import 'helpers.dart';      // Token extraction helper
import 'theme_notifier.dart';  // For theme management
import 'package:flutter/services.dart';

class ChatPage extends StatefulWidget {
  final int chatId;

  const ChatPage({super.key, required this.chatId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int? _selectedMessageIndex;
  Map? _repliedMessage;

  final List<dynamic> _messages = [];
  final Map<dynamic, dynamic> _chatInfo = {};
  String? _userId;
  final GlobalKey _listViewKey = GlobalKey();
  late WebSocketService _webSocketService;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  bool _isFetchingOldMessages = false;
  bool _hasMoreMessages = true; // To avoid unnecessary fetching when no more messages exist
  final int _limit = 10; // Pagination limit
  int _offset = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _webSocketService = WebSocketService();
    _connectToWebSocket();

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels == 0) {
        _fetchOlderMessages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    await _loadUserId();
    await _fetchChatInfo();
    await _fetchMessages(initialLoad: true);
  }

  Future<void> _loadUserId() async {
    _userId = await extractUserIdFromToken();
  }

  Future<void> _fetchMessages({bool initialLoad = false}) async {
    setState(() => _isLoading = initialLoad);

    String? token = await _getAccessToken();
    if (token == null) {
      _handleError('No access token found.');
      setState(() => _isLoading = false);
      return;
    }

    final response = await _getMessagesFromApi(token);
    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data.isNotEmpty) {
        setState(() {
          if (_isFetchingOldMessages) {
            _messages.insertAll(0, data);
          } else {
            _messages.addAll(data);
          }
          _offset += _limit;
          if (initialLoad) _scrollToBottom();
        });
      } else {
        _hasMoreMessages = false;
      }
    } else {
      _handleError('Failed to fetch messages: ${response.statusCode}');
    }
  }

  Future<void> _fetchChatInfo() async {
    String? token = await _getAccessToken();
    if (token == null) {
      _handleError('No access token found.');
      return;
    }

    final chatUrl = '${ApiConfig.baseUrl}/chats/my-chats/${widget.chatId}';
    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(chatUrl), headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data = jsonDecode(response.body);
      if (data != null && data.isNotEmpty) {
        setState(() {
          _chatInfo.addAll(data);
        });
      }
    } else {
      _handleError('Failed to fetch chat info: ${response.statusCode}');
    }
  }

  Future<void> _fetchOlderMessages() async {
    if (!_hasMoreMessages) return; // Stop fetching if no more messages

    setState(() {
      _isFetchingOldMessages = true;
    });
    await _fetchMessages(); // Fetch older messages and prepend
    setState(() {
      _isFetchingOldMessages = false;
    });
  }

  Future<String?> _getAccessToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  void _connectToWebSocket() async {
    String? token = await _getAccessToken();
    if (token != null) {
      _webSocketService.connect(token, _handleIncomingMessage);
    } else {
      _handleError('No access token found for WebSocket.');
    }
  }

  void _handleIncomingMessage(String data) {
    final message = jsonDecode(data);
    if (message['event'] == 'new_message') {
      setState(() {
        _messages.add(message['data']);
      });
      _scrollToBottom();
    }
    else if (message['event'] == 'delete_message') {
      setState(() {
        _messages.removeWhere((message1) => message1['id'] == message['data']);
        _selectedMessageIndex = null;
      });
    }
    else if (message['event'] == 'message_reaction') {
      var messageToUpdate = _messages.firstWhere(
            (message1) => message1['id'] == message['data']['message_id'],
        orElse: () => null,
      );
      setState(() {
        if (messageToUpdate['reactions'] == null) {
          messageToUpdate['reactions'] = {};
        }
        if (messageToUpdate['reactions'].containsKey(_userId)) {
          messageToUpdate['reactions'] =
          {message['data']['user_id']: message['data']['reaction']};
        } else {
          messageToUpdate['reactions'] =
          {message['data']['user_id']: message['data']['reaction']};
        }
        _selectedMessageIndex = null;
      });
    }
  }

  Future<http.Response> _getMessagesFromApi(String token) async {
    final messagesUrl = '${ApiConfig
        .baseUrl}/chats/my-chats/messages/?limit=$_limit&offset=$_offset&chat_id=${widget
        .chatId}';
    final headers = {
      'accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    return await http.get(Uri.parse(messagesUrl), headers: headers);
  }

  void _sendMessage() {
    final messageContent = _messageController.text.trim();

    if (messageContent.isEmpty) {
      _handleError('Message cannot be empty.');
      return;
    }
    final messagePayload = _buildMessagePayload('new_message', content: messageContent);
    _webSocketService.sendMessage(messagePayload);

    _clearInput();
    _resetReplyState();
  }

  void _deleteMessage(Map message) {
    final messageId = message['id'];
    final messagePayload = _buildMessagePayload('delete_message', messageId: messageId);
    print(messagePayload);
    _webSocketService.sendMessage(messagePayload);

    setState(() {
      _selectedMessageIndex = null;
    });
  }

  String _buildMessagePayload(String eventType, {String? content, int? messageId}) {
    return jsonEncode({
      'event_type': eventType,
      'event_data': {
        'content': content,
        'chat_id': widget.chatId,
        'user_id': _userId,
        'message_id': messageId,
        'reply_to_id': _repliedMessage != null ? _repliedMessage!['id'] : null,  // Include reply_id if there is a reply
        'reply_to_user_id': _repliedMessage != null ? _repliedMessage!['sender_info']['user_id'] : null,  // Include reply_id if there is a reply
        'reply_to_content': _repliedMessage != null ? _repliedMessage!['content'] : null,  // Include reply_id if there is a reply
      },
    });
  }

  void _clearInput() {
    _messageController.clear();
  }

  void _resetReplyState() {
    setState(() {
      _repliedMessage = null;
    });
  }


  void _handleError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          // Adjust duration as needed
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addReaction(String reaction, Map message) {
    final reaction_data = jsonEncode({
      'event_type': 'message_reaction',
      'event_data': {
        'reaction': reaction,
        'message_id': message['id'],
        'chat_id': _chatInfo['id'],
        'user_id': _userId,
      },
    });

    _webSocketService.sendMessage(reaction_data);
    _messageController.clear();
  }

  void _selectMessage(int index) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedMessageIndex = _selectedMessageIndex == index ? null : index;
    });
  }

  void _unselectMesaage() {
    setState(() {
      _selectedMessageIndex = null;
    });
  }

  void _copyMessage(String messageContent) {
    Clipboard.setData(ClipboardData(text: messageContent)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message copied')),
      );
    });
  }

  String _getTimeDifference(String lastUpdated) {
    DateTime lastUpdatedDate = DateTime.parse(lastUpdated);
    String formattedTime = '${lastUpdatedDate.hour.toString().padLeft(
        2, '0')}:${lastUpdatedDate.minute.toString().padLeft(2, '0')}';
    return formattedTime;
  }

  Widget _buildReactionMenu(int index, Map message) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.currentTheme.brightness == Brightness.dark;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDarkMode ? Colors.black : const Color(0xffececec),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Text("😊", style: TextStyle(fontSize: 22)),
            onPressed: () => _addReaction("😊", message),
          ),
          IconButton(
            icon: const Text("❤️", style: TextStyle(fontSize: 22)),
            onPressed: () => _addReaction("❤️", message),
          ),
          IconButton(
            icon: const Text("👍", style: TextStyle(fontSize: 22)),
            onPressed: () => _addReaction("👍", message),
          ),
          IconButton(
            icon: const Text("😅", style: TextStyle(fontSize: 22)),
            onPressed: () => _addReaction("😅", message),
          ),
          IconButton(
            icon: const Text("😡", style: TextStyle(fontSize: 22)),
            onPressed: () => _addReaction("😡", message),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsMenu(Map message) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.currentTheme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: 140,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : const Color(0xffececec),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.reply, color: isDarkMode ? Colors.white : Colors.black),
            title: Text('Reply', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              setState(() {
                _selectedMessageIndex = null;
                _repliedMessage = message;
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.copy, color: isDarkMode ? Colors.white : Colors.black),
            title: Text('Copy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              setState(() {
                _copyMessage(message['content']);
                _selectedMessageIndex = null;
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.edit, color: isDarkMode ? Colors.white : Colors.black),
            title: Text('Edit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
            onTap: () {
              setState(() {
                _selectedMessageIndex = null;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
            onTap: () {
              _deleteMessage(message); // Call delete message handler
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.currentTheme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: _unselectMesaage,
      child: Scaffold(
          backgroundColor: isDarkMode ?
          const Color(0xFF1B1B1B) :
          const Color(0xFFffffff),
          body: Column(
            children: [
              AppBar(
                backgroundColor: isDarkMode ?
                const Color(0xFF000000) :
                const Color(0xffffffff),
                title: Text(
                  _chatInfo['name'] ?? 'Chat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'KdamThmorPro',
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                iconTheme: IconThemeData(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  key: _listViewKey,
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessageBubble(_messages[index], index),
                ),
              ),
              _buildMessageInput(context),
            ],
          )
      ),
    );
  }

  Widget _buildMessageBubble(message, int index) {
    final isOtherSelected = _selectedMessageIndex != null &&
        _selectedMessageIndex != index;

    return GestureDetector(
      onLongPress: () => _selectMessage(index),
      onDoubleTap: () => _addReaction("❤️", message),
      child: Stack(
        children: [
          if (isOtherSelected)
            Blur(
              blur: 2.0,
              colorOpacity: 0,
              blurColor: Colors.transparent,
              child: _buildMessageContent(message, index),
            )
          else
            _buildMessageContent(message, index),
        ],
      ),
    );
  }
  Widget _buildMessageContent(message, int index) {
    final bool isCurrentUser = message['sender_info']['user_id'].toString() == _userId.toString();
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String username = message['sender_info']['username'];
    final String? replyContent = message['reply_to_content'];
    int _replyMessageLines = 2; // Default number of lines

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Row(
          mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              UsernameCircle(size: 15.0, username: username, isDarkMode: isDarkMode),
            Column(
              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (_selectedMessageIndex == index) _buildReactionMenu(message['id'], message),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrentUser ? _getUserMessageColor() : _getOtherUserMessageColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (replyContent != null)
                          StatefulBuilder(
                            builder: (context, setLocalState) {
                              return GestureDetector(
                                onTap: () {
                                  setLocalState(() {
                                    _replyMessageLines = _replyMessageLines == 2 ? 999 : 2;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(bottom: 5),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    replyContent,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white70 : Colors.black87,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'KdamThmorPro',
                                    ),
                                    maxLines: _replyMessageLines,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            },
                          ),
                        Text(
                          message['content'],
                          style: TextStyle(
                            fontSize: 16,
                            color: isCurrentUser ? Colors.white : Colors.black,
                            fontFamily: 'KdamThmorPro',
                          ),
                        ),
                        Text(
                          _getTimeDifference(message['sent_at']),
                          style: TextStyle(
                            fontSize: 12,
                            color: isCurrentUser ? Colors.white : Colors.black54,
                            fontFamily: 'KdamThmorPro',
                          ),
                        ),
                        if (message['reactions'] != null && message['reactions'] is Map)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                children: message['reactions'].entries.map<Widget>((entry) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xfff3f3f3),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5, top: 2, right: 5, bottom: 2),
                                      child: Row(
                                        children: [
                                          UsernameCircle(size: 12.0, username: username, isDarkMode: isDarkMode),
                                          Text(
                                            '${entry.value}',
                                            style: const TextStyle(fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                if (_selectedMessageIndex == index) _buildOptionsMenu(message),
              ],
            ),
            if (isCurrentUser)
              UsernameCircle(size: 15.0, username: username, isDarkMode: isDarkMode),
          ],
        ),
      ),
    );
  }



  Color _getUserMessageColor() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.currentTheme.brightness == Brightness.dark;
    return isDarkMode ?
    const Color(0xff524296) :
    const Color(0xff1fc9f8);
  }

  Color _getOtherUserMessageColor() {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.currentTheme.brightness == Brightness.dark;
    return isDarkMode ?
    const Color(0xff0c0c0c) :
    const Color(0xff7d7ded);
  }

  Widget _buildMessageInput(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.currentTheme.brightness == Brightness.dark;

    return Column(
      children: [
        // Display the replied message if there is one
        if (_repliedMessage != null)
          Container(
            padding: const EdgeInsets.all(10.0),
            color: isDarkMode ? const Color(0xFF333333) : const Color(
                0xffe0e0e0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Replying to: ${_repliedMessage!['content']}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close,
                      color: isDarkMode ? Colors.white : Colors.black),
                  onPressed: () {
                    setState(() {
                      _repliedMessage = null; // Clear the replied message
                    });
                  },
                ),
              ],
            ),
          ),
        Container(
          color: isDarkMode ? const Color(0xFF000000) : const Color(0xfff4f4f4),
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xff0c0c0c) : const Color(
                        0xffececec),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery
                          .of(context)
                          .size
                          .height * 0.2, // Limit height to 20% of screen height
                    ),
                    child: Scrollbar(
                      child: TextField(
                        controller: _messageController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontFamily: 'KdamThmorPro',
                        ),
                        maxLines: null,
                        // Allows the input to expand vertically
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.white54 : Colors.black54,
                            fontFamily: 'KdamThmorPro',
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        onSubmitted: (value) => _sendMessage(),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: isDarkMode ? Colors.white : Colors.blue,
                ),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UsernameCircle extends StatelessWidget {
  final String username;
  final bool isDarkMode;
  final double size;

  const UsernameCircle({
    super.key,
    required this.username,
    required this.isDarkMode, // Add isDarkMode as a required parameter
    required this.size, // Add isDarkMode as a required parameter
  });

  @override
  Widget build(BuildContext context) {
    // Get the first letter of the username
    String firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return CircleAvatar(
      radius: size, // Adjust the radius as needed
      backgroundColor: Colors.black, // Use isDarkMode for background color
      child: Text(
        firstLetter,
        style: TextStyle(
          fontFamily: 'KdamThmorPro',
          color: Colors.white, // Adjust text color based on dark mode
          fontSize: size + 4, // Text size
          fontWeight: FontWeight.bold, // Text weight
        ),
      ),
    );
  }
}