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
  int messageIndex = -1;
  final FocusNode _myFocusNode = FocusNode();
  bool editMessage = false;
  String messageId = "";

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
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                if (!editMessage) {
                  setState(() {
                    messageIndex = -1;
                    editMessage = false;
                    messageId = "";
                  });
                }
              },
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
                                          (currentUser?.email ==
                                                      messages[index]
                                                          ['senderEmail']) &&
                                                  index == messageIndex
                                              ? Row(
                                                  children: [
                                                    IconButton(
                                                        onPressed: () {
                                                          if (editMessage) {
                                                            setState(() {
                                                              messageController
                                                                  .clear();
                                                              _myFocusNode
                                                                  .unfocus();
                                                              messageId = "";
                                                              editMessage =
                                                                  false;
                                                              messageIndex = -1;
                                                            });
                                                          } else {
                                                            setState(() {
                                                              editMessage =
                                                                  true;
                                                              messageId =
                                                                  messages[
                                                                          index]
                                                                      ['id'];
                                                            });
                                                            messageController
                                                                    .text =
                                                                messages[index]
                                                                    ['message'];
                                                            _myFocusNode
                                                                .requestFocus();
                                                          }
                                                        },
                                                        icon: editMessage
                                                            ? const Icon(
                                                                Icons.edit_off)
                                                            : const Icon(
                                                                Icons.edit)),
                                                    IconButton(
                                                        onPressed: () {
                                                          messages[index][
                                                                      'senderEmail'] ==
                                                                  currentUser!
                                                                      .email
                                                              ? showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return AlertDialog(
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(24.0),
                                                                      ),
                                                                      contentPadding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          24,
                                                                          20,
                                                                          24,
                                                                          8),
                                                                      titlePadding: const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              16),
                                                                      title:
                                                                          const Column(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.delete,
                                                                            size:
                                                                                48,
                                                                          ),
                                                                          SizedBox(
                                                                              height: 12),
                                                                          Text(
                                                                            "Supprimer un message ?",
                                                                            style:
                                                                                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      content:
                                                                          const Text(
                                                                        'Êtes-vous sûr de vouloir supprimer ce message ? Cette action est irréversible.',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Colors.black87,
                                                                        ),
                                                                      ),
                                                                      actionsPadding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              12,
                                                                          right:
                                                                              16,
                                                                          left:
                                                                              16),
                                                                      actionsAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      actions: [
                                                                        OutlinedButton(
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              messageIndex = -1;
                                                                            });
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          style:
                                                                              OutlinedButton.styleFrom(
                                                                            shape:
                                                                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                                            side:
                                                                                const BorderSide(color: Colors.grey),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                                          ),
                                                                          child:
                                                                              const Text(
                                                                            'Annuler',
                                                                            style:
                                                                                TextStyle(fontSize: 16, color: Colors.black87),
                                                                          ),
                                                                        ),
                                                                        ElevatedButton(
                                                                          onPressed:
                                                                              () async {
                                                                            final messagesProvider =
                                                                                Provider.of<MessagesProvider>(context, listen: false);
                                                                            await messagesService.deleteMessage(messages[index]['id']);
                                                                            await messagesProvider.getAllMessagesByGroupId(widget.group['id']);
                                                                            setState(() {
                                                                              messageIndex = -1;
                                                                            });
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                Colors.black87,
                                                                            shape:
                                                                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                                            padding:
                                                                                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                                          ),
                                                                          child:
                                                                              const Text(
                                                                            'Supprimer',
                                                                            style:
                                                                                TextStyle(fontSize: 16, color: Colors.white),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                )
                                                              : Container();
                                                        },
                                                        icon: const Icon(
                                                            Icons.delete)),
                                                  ],
                                                )
                                              : Container(),
                                          Padding(
                                            padding: (index == 0) &&
                                                    (currentUser?.email ==
                                                        messages[index]
                                                            ['senderEmail'])
                                                ? const EdgeInsets.only(
                                                    right: 16.0,
                                                    left: 6.0,
                                                    top: 1.0,
                                                    bottom: 10.0)
                                                : (index == 0) &&
                                                        (currentUser?.email !=
                                                            messages[index]
                                                                ['senderEmail'])
                                                    ? const EdgeInsets.only(
                                                        right: 16.0,
                                                        left: 16.0,
                                                        top: 1.0,
                                                        bottom: 10.0)
                                                    : index < messages.length - 1 &&
                                                            (messages[index + 1]['senderEmail'] ==
                                                                messages[index][
                                                                    'senderEmail']) &&
                                                            (currentUser?.email ==
                                                                messages[index][
                                                                    'senderEmail'])
                                                        ? const EdgeInsets.only(
                                                            right: 16.0,
                                                            left: 6.0,
                                                            top: 1.0,
                                                            bottom: 1.0)
                                                        : index < messages.length - 1 &&
                                                                (messages[index + 1]['senderEmail'] ==
                                                                    messages[index]
                                                                        [
                                                                        'senderEmail']) &&
                                                                (currentUser?.email !=
                                                                    messages[index]
                                                                        ['senderEmail'])
                                                            ? const EdgeInsets.only(right: 16.0, left: 16.0, top: 1.0, bottom: 1.0)
                                                            : (index != 0) && (currentUser?.email == messages[index]['senderEmail'])
                                                                ? const EdgeInsets.only(right: 16.0, left: 6.0, top: 12.0, bottom: 1.0)
                                                                : const EdgeInsets.only(right: 16.0, left: 16.0, top: 12.0, bottom: 1.0),
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
                                                GestureDetector(
                                                  onLongPress: () {
                                                    setState(() {
                                                      messageIndex = index;
                                                    });
                                                  },
                                                  child: Container(
                                                      constraints: BoxConstraints(
                                                          maxWidth: (editMessage && messageIndex == index) ||
                                                                  messageIndex ==
                                                                      index
                                                              ? MediaQuery.of(context)
                                                                      .size
                                                                      .width *
                                                                  0.60
                                                              : MediaQuery.of(context)
                                                                      .size
                                                                      .width *
                                                                  0.70),
                                                      decoration: BoxDecoration(
                                                          color: currentUser
                                                                      ?.email ==
                                                                  messages[index]
                                                                      [
                                                                      'senderEmail']
                                                              ? Colors
                                                                  .blueAccent
                                                              : Colors
                                                                  .grey[200],
                                                          borderRadius:
                                                              BorderRadius.circular(20.0)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 10.0,
                                                                bottom: 10.0,
                                                                left: 14.0,
                                                                right: 14.0),
                                                        child: messages[index][
                                                                    'status'] ==
                                                                'DELETED'
                                                            ? const Text(
                                                                "Message supprimé",
                                                                style: TextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              )
                                                            : Text(
                                                                messages[index]
                                                                    ['message'],
                                                                style: TextStyle(
                                                                    color: currentUser?.email ==
                                                                            messages[index][
                                                                                'senderEmail']
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black),
                                                              ),
                                                      )),
                                                ),
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
                                      focusNode: _myFocusNode,
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
                                          if (editMessage == true) {
                                            await messagesService.editMessage(
                                                messageController.text,
                                                messageId);
                                            _myFocusNode.unfocus();
                                          } else {
                                            await messagesService.sendMessage(
                                                messageController.text,
                                                widget.group['id'],
                                                currentUser?.email);
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
                                          }
                                          messageController.clear();
                                          await messagesProvider
                                              .getAllMessagesByGroupId(
                                                  widget.group['id']);
                                          setState(() {
                                            messageIndex = -1;
                                            editMessage = false;
                                            messageId = "";
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
