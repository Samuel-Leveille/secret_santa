import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
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
                        Container(
                          height: MediaQuery.of(context).size.height * 0.78,
                          width: MediaQuery.of(context).size.width,
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
                                    decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                      hintText: "Message",
                                      hintStyle:
                                          TextStyle(color: Colors.blueAccent),
                                      border: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.blue)),
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
                                    await messagesService.sendMessage(
                                        messageController.text,
                                        widget.group['id'],
                                        currentUser?.email);
                                    messageController.clear();
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
