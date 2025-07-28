import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/providers/messages_provider.dart';
import 'package:secret_santa/services/messages_service.dart';

class GroupChatPage extends StatefulWidget {
  final Map<String, dynamic> group;
  const GroupChatPage({super.key, required this.group});

  @override
  State<GroupChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<GroupChatPage> {
  TextEditingController messageController = TextEditingController();
  MessagesService messagesService = MessagesService();
  User? currentUser = FirebaseAuth.instance.currentUser;
  MessagesProvider? messagesProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      messagesProvider = Provider.of<MessagesProvider>(context, listen: false);
      messagesProvider?.clearMessages();
      await messagesProvider?.getAllMessagesByGroupId(widget.group['id']);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.minScrollExtent);
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: Text(
                widget.group['name'],
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              backgroundColor: Colors.white,
              scrolledUnderElevation: 0.0,
            ),
            body: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Consumer<MessagesProvider>(
                          builder: (context, provider, child) {
                            List<Map<String, dynamic>> messages =
                                provider.messages;
                            return Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.78,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                    reverse: true,
                                    controller: _scrollController,
                                    itemCount: messages.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Row(
                                        mainAxisAlignment: currentUser?.email ==
                                                messages[index]['senderEmail']
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16.0,
                                                left: 16.0,
                                                top: 6.0,
                                                bottom: 6.0),
                                            child: Container(
                                                constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.70,
                                                ),
                                                decoration: BoxDecoration(
                                                    color: currentUser?.email ==
                                                            messages[index]
                                                                ['senderEmail']
                                                        ? Colors.blueAccent
                                                        : Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 10.0,
                                                          bottom: 10.0,
                                                          left: 14.0,
                                                          right: 14.0),
                                                  child: Text(
                                                    messages[index]['message'],
                                                    style: TextStyle(
                                                        color: currentUser
                                                                    ?.email ==
                                                                messages[index][
                                                                    'senderEmail']
                                                            ? Colors.white
                                                            : Colors.black),
                                                  ),
                                                )),
                                          ),
                                        ],
                                      );
                                    }));
                          },
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: messageController,
                                    minLines: 1,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 12),
                                      hintText: "Message",
                                      hintStyle: const TextStyle(
                                          color: Colors.blueAccent),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          borderSide: const BorderSide(
                                              color: Colors.blue)),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                MaterialButton(
                                  minWidth: 67,
                                  color: Colors.blueAccent,
                                  elevation: 0,
                                  onPressed: () async {
                                    final messagesProvider =
                                        Provider.of<MessagesProvider>(context,
                                            listen: false);
                                    await messagesService.sendMessage(
                                        messageController.text,
                                        widget.group['id'],
                                        currentUser?.email);
                                    messageController.clear();
                                    await messagesProvider
                                        .getAllMessagesByGroupId(
                                            widget.group['id']);
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      _scrollController.animateTo(
                                        _scrollController
                                            .position.minScrollExtent,
                                        duration:
                                            const Duration(milliseconds: 100),
                                        curve: Curves.easeOut,
                                      );
                                    });
                                  },
                                  child: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )),
            )),
      ),
    );
  }
}
