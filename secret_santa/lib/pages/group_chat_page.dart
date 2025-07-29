import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/providers/messages_provider.dart';
import 'package:secret_santa/services/messages_service.dart';
import 'package:secret_santa/services/users_service.dart';

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
  final UsersService usersService = UsersService();

  @override
  void initState() {
    messageController.addListener(() {
      setState(() {});
    });
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
                                            padding: index == 0
                                                ? const EdgeInsets.only(
                                                    right: 16.0,
                                                    left: 16.0,
                                                    top: 1.0,
                                                    bottom: 10.0)
                                                : index < messages.length - 1 &&
                                                        (messages[index + 1][
                                                                'senderEmail'] ==
                                                            messages[index]
                                                                ['senderEmail'])
                                                    ? const EdgeInsets.only(
                                                        right: 16.0,
                                                        left: 16.0,
                                                        top: 1.0,
                                                        bottom: 1.0)
                                                    : const EdgeInsets.only(
                                                        right: 16.0,
                                                        left: 16.0,
                                                        top: 12.0,
                                                        bottom: 1.0),
                                            child: Column(
                                              crossAxisAlignment: currentUser
                                                          ?.email ==
                                                      messages[index]
                                                          ['senderEmail']
                                                  ? CrossAxisAlignment.end
                                                  : CrossAxisAlignment.start,
                                              children: [
                                                (index < messages.length - 1 &&
                                                            (messages[index][
                                                                    'senderEmail'] !=
                                                                messages[index +
                                                                        1][
                                                                    'senderEmail']) &&
                                                            (messages[index][
                                                                    'senderEmail'] !=
                                                                currentUser
                                                                    ?.email)) ||
                                                        (index ==
                                                                messages.length -
                                                                    1) &&
                                                            (messages[index][
                                                                    'senderEmail'] !=
                                                                currentUser
                                                                    ?.email)
                                                    ? FutureBuilder<String>(
                                                        future: usersService
                                                            .getUserNameByEmail(
                                                                messages[index][
                                                                    'senderEmail']),
                                                        builder: (context,
                                                            snapshot) {
                                                          return Text(
                                                            snapshot.data ??
                                                                "Utilisateur",
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          );
                                                        },
                                                      )
                                                    : Container(),
                                                Container(
                                                    constraints: BoxConstraints(
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.70,
                                                    ),
                                                    decoration: BoxDecoration(
                                                        color: currentUser
                                                                    ?.email ==
                                                                messages[index][
                                                                    'senderEmail']
                                                            ? Colors.blueAccent
                                                            : Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    20.0)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 10.0,
                                                              bottom: 10.0,
                                                              left: 14.0,
                                                              right: 14.0),
                                                      child: Text(
                                                        messages[index]
                                                            ['message'],
                                                        style: TextStyle(
                                                            color: currentUser
                                                                        ?.email ==
                                                                    messages[
                                                                            index]
                                                                        [
                                                                        'senderEmail']
                                                                ? Colors.white
                                                                : Colors.black),
                                                      ),
                                                    )),
                                              ],
                                            ),
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
                                left: 18.0,
                                right: 18.0,
                                top: 18.0,
                                bottom: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: TextField(
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      controller: messageController,
                                      minLines: 1,
                                      maxLines: 5,
                                      decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 16),
                                          hintText: "Message",
                                          hintStyle: TextStyle(
                                              color: Colors.grey[600]),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                messageController.value.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () async {
                                          final messagesProvider =
                                              Provider.of<MessagesProvider>(
                                                  context,
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
                                              duration: const Duration(
                                                  milliseconds: 100),
                                              curve: Curves.easeOut,
                                            );
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.send,
                                          color: Colors.blueAccent,
                                          size: 28,
                                        ))
                                    : Container()
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
