import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/theme_providers.dart';

class ThemeSelectionDialogState extends StatefulWidget {
  const ThemeSelectionDialogState({super.key});

  @override
  State<ThemeSelectionDialogState> createState() =>
      _ThemeSelectionDialogStateState();
}

class _ThemeSelectionDialogStateState extends State<ThemeSelectionDialogState> {
  String groupValue = 'dark';
  bool light = true;
  bool dark = false;

  @override
  void initState() {
    super.initState();
    getValue();
  }

  void saveValue(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('groupvalue', value);
  }

  void getValue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final fetchedVale = prefs.getString('groupvalue');
    if (fetchedVale != null) {
      setState(() {
        groupValue = fetchedVale;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).canvasColor;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      title: Text(
        'Choose theme',
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: 20,
            overflow: TextOverflow.ellipsis),
        maxLines: 1,
      ),
      content: SizedBox(
        height: 160,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Radio(
                    activeColor: Colors.blue,
                    value: 'light',
                    groupValue: groupValue,
                    onChanged: (selectedValue) {
                      setState(() {
                        groupValue = selectedValue!;
                      });
                      saveValue(selectedValue!);
                    }),
                Text(
                  'Light',
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Radio(
                    activeColor: Colors.blue,
                    value: 'dark',
                    groupValue: groupValue,
                    onChanged: (selectedValue) {
                      setState(() {
                        groupValue = selectedValue!;
                      });
                      saveValue(selectedValue!);
                    }),
                Text(
                  'Dark',
                  style: TextStyle(color: textColor),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    groupValue == 'light'
                        ? Provider.of<ThemeProvider>(context, listen: false)
                            .changeToLight()
                        : Provider.of<ThemeProvider>(context, listen: false)
                            .changeToDark();
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Ok',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
