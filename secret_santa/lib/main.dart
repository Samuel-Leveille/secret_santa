import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/pages/login_page.dart';
import 'package:secret_santa/providers/gifts_provider.dart';
import 'package:secret_santa/providers/groups_firestore_provider.dart';
import 'package:secret_santa/providers/messages_provider.dart';
import 'package:secret_santa/providers/pige_provider.dart';
import 'package:secret_santa/providers/users_firestore_provider.dart';
import 'package:secret_santa/providers/gift_images_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsersFirestoreProvider()),
        ChangeNotifierProvider(create: (_) => GroupsFirestoreProvider()),
        ChangeNotifierProvider(create: (_) => GiftImagesProvider()),
        ChangeNotifierProvider(create: (_) => GiftsProvider()),
        ChangeNotifierProvider(create: (_) => PigeProvider()),
        ChangeNotifierProvider(create: (_) => MessagesProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: "Montserrat"),
        home: const LoginPage(),
      ),
    );
  }
}
