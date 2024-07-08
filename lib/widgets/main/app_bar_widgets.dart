import 'package:flutter/material.dart';

class AppBarWidgets {
  Widget leading(func) {
    return IconButton(
      onPressed: func,
      icon: const Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
    );
  }

  Widget titleA(onChanged, TextEditingController controller) {
    return TextField(
      //autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search...',
        hintStyle: TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 2.0),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
      ),
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      controller: controller,
      cursorColor: Colors.blue,
    );
  }

  Widget titleB() {
    return const Text(
      'mG-chat',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
