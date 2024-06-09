import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({required this.onPickImage, super.key});
  final void Function(File pickedImage) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? pickedImageFile;
  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
      maxWidth: 720,
      maxHeight: 720,
    );
    if (pickedImage == null) return;

    setState(() {
      pickedImageFile = File(pickedImage.path);
    });
    widget.onPickImage(pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          foregroundImage:
              pickedImageFile != null ? FileImage(pickedImageFile!) : null,
        ),
        TextButton.icon(
            onPressed: _pickImage,
            icon: Icon(
              Icons.image,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            label: Text(
              'Add Image',
              style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
            ))
      ],
    );
  }
}
