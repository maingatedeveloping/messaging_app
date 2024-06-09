import 'package:flutter/material.dart';

import '../../providers/theme_providers.dart';
import 'package:provider/provider.dart';

import 'theme_dialog.dart';

class AppThemeMode extends StatelessWidget {
  final Function closeProfilePic;
  const AppThemeMode({super.key, required this.closeProfilePic});

  @override
  Widget build(BuildContext context) {
    final tertiaryColor = Theme.of(context).colorScheme.tertiary;
    final textColor = Theme.of(context).canvasColor;

    return ListTile(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return const ThemeSelectionDialogState();
            });
        closeProfilePic();
      },
      leading: Icon(
        Icons.color_lens,
        color: tertiaryColor,
      ),
      title: Text(
        'Theme',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        Provider.of<ThemeProvider>(context).currrentMode,
        style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}
