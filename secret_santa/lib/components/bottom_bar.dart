import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:secret_santa/pages/accueil_page.dart';
import 'package:secret_santa/pages/add_group_page.dart';
import 'package:secret_santa/pages/chat_page.dart';
import 'package:secret_santa/pages/friends_page.dart';
import 'package:secret_santa/pages/profile_page.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedPageIndex = 0;
  late Future<String?> _currentUserEmailFuture;

  @override
  void initState() {
    super.initState();
    _currentUserEmailFuture = _fetchCurrentUserEmail();
  }

  Future<String?> _fetchCurrentUserEmail() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.email;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _currentUserEmailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final currentUserEmail = snapshot.data;

        if (currentUserEmail == null) {
          return const Scaffold(
            body: Center(child: Text('Aucun utilisateur connecté')),
          );
        }

        final List<Widget> _pages = [
          const AccueilPage(),
          ProfilePage(email: currentUserEmail),
          const AddGroupPage(),
          const FriendsPage(),
          const ChatPage(),
        ];

        return Scaffold(
          body: _pages[_selectedPageIndex],
          bottomNavigationBar: CurvedNavigationBar(
            backgroundColor: Colors.white,
            color: const Color.fromARGB(255, 175, 216, 250),
            buttonBackgroundColor: const Color.fromARGB(255, 175, 216, 250),
            height: 60,
            items: const <Widget>[
              Icon(Icons.home, size: 30),
              Icon(Icons.person, size: 30),
              Icon(Icons.add, size: 30),
              Icon(Icons.people, size: 30),
              Icon(Icons.chat, size: 30),
            ],
            onTap: _onItemTapped,
            index: _selectedPageIndex,
            animationDuration: const Duration(milliseconds: 300),
            animationCurve: Curves.easeInOut,
          ),
        );
      },
    );
  }
}
