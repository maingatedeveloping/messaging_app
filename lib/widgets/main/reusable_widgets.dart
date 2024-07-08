import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../profile/edit_profile_screen.dart';
import '../profile/image_profile_detail_screen.dart';

Widget stackPhoto(ctx, closeProfilePic, bool secondStack, String userImage,
    String username, String about) {
  return Center(
    child: InkWell(
      onTap: () {
        Navigator.of(ctx).push(
          PageRouteBuilder(
            pageBuilder: ((context, animation, secondaryAnimation) {
              return ProfileImageScreen(
                imageUrl: userImage,
                userName: username,
              );
            }),
            transitionDuration: const Duration(
              microseconds: 0,
            ),
          ),
        );
        closeProfilePic();
      },
      child: Stack(children: [
        Container(
          color: Colors.blue,
          height: 200,
          width: 200,
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: userImage,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
        secondStack
            ? Positioned(
                right: 10,
                child: IconButton(
                  onPressed: () {
                    Navigator.of(ctx).push(
                      PageRouteBuilder(
                        pageBuilder: ((context, animation, secondaryAnimation) {
                          return EditProfileScreen(username, userImage, about);
                        }),
                        transitionDuration: const Duration(
                          microseconds: 0,
                        ),
                      ),
                    );
                    closeProfilePic();
                  },
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(ctx).canvasColor,
                  ),
                ),
              )
            : const SizedBox(height: 0),
      ]),
    ),
  );
}
