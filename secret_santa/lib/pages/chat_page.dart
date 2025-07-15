import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/providers/groups_firestore_provider.dart';
import 'package:secret_santa/providers/pige_provider.dart';
import 'package:secret_santa/services/groups_service.dart';
import 'package:secret_santa/services/pige_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TabController? _tabController;
  PageController? _pageController;
  PigeProvider? pigeProvider;
  GroupsFirestoreProvider? groupsProvider;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      groupsProvider =
          Provider.of<GroupsFirestoreProvider>(context, listen: false);
      pigeProvider = Provider.of<PigeProvider>(context, listen: false);
      await groupsProvider?.fetchGroupsData();
      await pigeProvider?.fetchAllPigeDuos();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: Container(
              color: Colors.white,
              child: Column(
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.only(left: 25.0, top: 70, bottom: 20),
                        child: Text(
                          "Clavardage",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Consumer2<GroupsFirestoreProvider, PigeProvider>(
                    builder: (context, groupsProvider, pigeProvider, child) {
                      return Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            _tabController?.animateTo(index);
                          },
                          children: [
                            GroupChatList(groups: groupsProvider.groupsData),
                            PigeChatList(
                              pigesEmailAndGroupId: pigeProvider.pigeDuoMap,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

class GroupChatList extends StatelessWidget {
  final List<Map<String, dynamic>> groups;
  const GroupChatList({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    print("groups : ${groups}");
    return ListView.builder(itemBuilder: (context, index) {});
  }
}

class PigeChatList extends StatelessWidget {
  final Map<String, dynamic> pigesEmailAndGroupId;
  const PigeChatList({super.key, required this.pigesEmailAndGroupId});

  @override
  Widget build(BuildContext context) {
    print("Piges emails and groups Id : ${pigesEmailAndGroupId}");
    return ListView.builder(itemBuilder: (context, index) {});
  }
}
