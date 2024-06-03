import 'package:flutter/cupertino.dart';
import 'package:secret_santa/pages/bottom_bar.dart';

class TransitionPage extends StatefulWidget {
  const TransitionPage({super.key});

  @override
  State<TransitionPage> createState() => _TransitionPageState();
}

class _TransitionPageState extends State<TransitionPage> {
  @override
  Widget build(BuildContext context) {
    return const BottomBar();
  }
}
