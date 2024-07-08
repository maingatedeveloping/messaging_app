import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ProfileImageScreen extends StatefulWidget {
  final String imageUrl;
  final String userName;
  const ProfileImageScreen(
      {required this.userName, super.key, required this.imageUrl});

  @override
  State<ProfileImageScreen> createState() => _ProfileImageScreenState();
}

class _ProfileImageScreenState extends State<ProfileImageScreen> {
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () {
            return Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: ListTile(
          title: Text(
            widget.userName,
            style: TextStyle(
              color: Theme.of(context).canvasColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Center(
        child: Container(
          color: Colors.blue,
          margin: const EdgeInsets.only(
            left: 10,
            right: 10,
          ),
          width: orientation == Orientation.portrait
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.height,
          height: orientation == Orientation.portrait
              ? MediaQuery.of(context).size.width
              : MediaQuery.of(context).size.height,
          child: PhotoView(
            imageProvider: CachedNetworkImageProvider(
              widget.imageUrl,
            ),
            minScale: PhotoViewComputedScale.covered * 1,
            maxScale: PhotoViewComputedScale.covered * 3,
            initialScale: PhotoViewComputedScale.covered,
          ),
        ),
      ),
    );
  }
}
