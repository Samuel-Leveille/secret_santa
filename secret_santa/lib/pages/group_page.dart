import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/utils/groups_firestore_provider.dart';

class GroupPage extends StatefulWidget {
  final String groupId;
  const GroupPage({super.key, required this.groupId});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  GroupsFirestoreProvider? _groupProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupProvider =
          Provider.of<GroupsFirestoreProvider>(context, listen: false);
      _groupProvider?.fetchGroupData(widget.groupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: Consumer<GroupsFirestoreProvider>(
        builder: (context, provider, child) {
          final group = provider.groupData;
          return Center(child: Text(group?['name']));
        },
      ),
    ));
  }
}
