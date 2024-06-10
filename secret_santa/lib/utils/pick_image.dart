import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImage(ImageSource source, String userId) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file == null) return null;

  final storageRef = FirebaseStorage.instance.ref();
  final imageRef = storageRef.child("$userId.jpg");
  final imageBytes = await _file.readAsBytes();
  await imageRef.putData(imageBytes);

  final imageUrl = await imageRef.getDownloadURL();
  print('Image URL: $imageUrl');

  try {
    print(userId);
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await userRef.update({'profileImageUrl': imageUrl});
  } catch (e) {
    print('Erreur lors de la mise à jour du document Firestore: $e');
  }

  return imageBytes;
}
