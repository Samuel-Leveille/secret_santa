import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/pages/group_chat_page.dart';
import 'package:secret_santa/providers/groups_firestore_provider.dart';
import 'package:secret_santa/providers/pige_provider.dart';
import 'package:secret_santa/services/groups_service.dart';
import 'package:secret_santa/services/users_service.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatListPage> with TickerProviderStateMixin {
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
    _pageController = PageController(initialPage: 0);
    _tabController = TabController(length: 2, vsync: this);

    _tabController?.addListener(() {
      if (_tabController!.indexIsChanging) {
        _pageController?.animateToPage(
          _tabController!.index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          body: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
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
                  TabBar(
                    labelColor: const Color.fromARGB(255, 134, 198, 250),
                    indicatorColor: const Color.fromARGB(255, 134, 198, 250),
                    controller: _tabController,
                    tabs: const [
                      Tab(
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.groups),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text('Groupes'),
                          ],
                        ),
                      ),
                      Tab(
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.question_answer),
                            SizedBox(
                              width: 8.0,
                            ),
                            Text('Piges'),
                          ],
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
    return groups.isNotEmpty
        ? ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                    top: index == 0 ? 16.0 : 8.0,
                    bottom: 8.0,
                    left: 16.0,
                    right: 16.0),
                child: Card(
                  color: const Color.fromARGB(255, 231, 245, 255),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Text(groups[index]['name'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                    trailing: SizedBox(
                      width: 70,
                      child: IconButton(
                        onPressed: () {
                          groups[index].isNotEmpty
                              ? Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => GroupChatPage(
                                        group: groups[index],
                                      )))
                              : ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    padding: EdgeInsets.only(
                                        top: 20.0, bottom: 20.0, left: 15),
                                    content: Text(
                                        "Le clavardage de ce groupe n'est pas accessible"),
                                  ),
                                );
                        },
                        icon: const Icon(Icons.chat_rounded),
                        iconSize: 30,
                        color: const Color.fromARGB(255, 110, 110, 110),
                      ),
                    ),
                  ),
                ),
              );
            })
        : const Center(
            child: Padding(
            padding: EdgeInsets.only(bottom: 40.0),
            child: Text(
              "Vous ne faites parti d'aucun groupe",
              style: TextStyle(fontSize: 24),
            ),
          ));
  }
}

class PigeChatList extends StatelessWidget {
  final Map<String, dynamic> pigesEmailAndGroupId;
  const PigeChatList({super.key, required this.pigesEmailAndGroupId});

  @override
  Widget build(BuildContext context) {
    GroupsService groupsService = GroupsService();
    UsersService usersService = UsersService();

    return pigesEmailAndGroupId.isNotEmpty
        ? ListView.builder(
            itemCount: pigesEmailAndGroupId.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                    top: index == 0 ? 16.0 : 8.0,
                    bottom: 8.0,
                    left: 16.0,
                    right: 16.0),
                child: Card(
                  color: const Color.fromARGB(255, 231, 245, 255),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder(
                          future: usersService.getUserNameByEmail(
                              pigesEmailAndGroupId.keys.elementAt(index)),
                          builder: (context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else {
                              return Text(snapshot.data.toString(),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500));
                            }
                          },
                        ),
                        FutureBuilder(
                          future: groupsService.getGroupNameById(
                              pigesEmailAndGroupId.values.elementAt(index)),
                          builder: (context, AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else {
                              return Text(snapshot.data.toString());
                            }
                          },
                        ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 70,
                      child: IconButton(
                        onPressed: () {
                          //friendsService.acceptFriendRequest(
                          //items[index], onRequestHandled);
                        },
                        icon: const Icon(Icons.chat_rounded),
                        iconSize: 30,
                        color: const Color.fromARGB(255, 110, 110, 110),
                      ),
                    ),
                  ),
                ),
              );
            })
        : const Center(
            child: Padding(
            padding: EdgeInsets.only(bottom: 40.0),
            child: Text(
              "Vous ne faites parti d'aucune pige",
              style: TextStyle(fontSize: 24),
            ),
          ));
  }
}
