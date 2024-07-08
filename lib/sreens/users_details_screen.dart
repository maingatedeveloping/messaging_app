import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UsersDetailScreens extends StatelessWidget {
  final String userName;
  final String imageUrl;
  const UsersDetailScreens(
      {super.key, required this.userName, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onSurface,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Details',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                trailing: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Remove User',
                    style: TextStyle(
                        color: Theme.of(context).canvasColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Text(
                userName,
                maxLines: 1,
                style: TextStyle(
                    color: Theme.of(context).canvasColor,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width * 0.3,
                    ),
                    child: Text(
                      'About',
                      style: TextStyle(color: Theme.of(context).canvasColor),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      'Life is how you make it',
                      style: TextStyle(
                        color: Theme.of(context).canvasColor,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              Container(
                color: Colors.blue,
                height: MediaQuery.of(context).size.height * 0.7,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: imageUrl,
                  errorWidget: (context, url, error) {
                    return const SizedBox(height: 0);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
