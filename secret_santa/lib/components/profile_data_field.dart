import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/utils/users_firestore_provider.dart';

class ProfileDataField extends StatelessWidget {
  final double width;
  final double height;
  final String content;
  final String label;
  final bool canModify;
  const ProfileDataField({
    super.key,
    required this.width,
    required this.height,
    required this.content,
    required this.label,
    required this.canModify,
  });

  @override
  Widget build(BuildContext context) {
    UsersFirestoreProvider usersFirestoreProvider =
        Provider.of<UsersFirestoreProvider>(context);

    return Container(
      width: width,
      height: height,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  content,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            canModify == true
                ? Positioned(
                    right: -10,
                    top: -15,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.edit),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
